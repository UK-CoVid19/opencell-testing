class TestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_test, only: [:show, :edit, :update, :destroy, :analyse, :confirm]
  before_action :set_plate, except: [:complete, :done]
  around_action :wrap_in_current_user, only: [:create, :confirm, :update, :createfile]
  after_action :verify_authorized

  # GET /tests
  # GET /tests.json

  def complete
    authorize Test
    @tests = Test.all.joins(:plate).where(plates: { state: Plate.states[:complete] })
  end

  def done
    authorize Test
    @tests = Test.all.includes(:result_file_attachment, :user, :plate).where(plates: { state: Plate.states[:analysed] })

    respond_to do |format|
      format.html
      format.json { render json: TestDatatable.new(params, view_context: view_context) }
    end
  end

  # GET /tests/1
  # GET /tests/1.json
  def show
  end

  # GET /tests/new
  def new
    @test_results = @plate.samples.map {|s| TestResult.new({well: s.well})}
    @test = Test.new({plate: @plate, test_results: @test_results})
    authorize @test
  end

  def analyse
    if @plate.analysed?
      flash[:alert] = "Invalid plate state to analyse"
      redirect_to(request.referrer || staff_dashboard_path) and return 
    end
  end

  # POST /tests
  # POST /tests.json
  def create
    tp = test_params.merge!(plate_id: params[:plate_id])
    @test = Test.new(tp)
    authorize Test
    respond_to do |format|
      if @test.save
        @test.plate.complete!
        format.html { redirect_to plate_url(@test.plate), notice: 'Test was successfully created.'}
        format.json { render :show, status: :created, location: test }
      else
        format.html { render :new, status: :unprocessable_entity}
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  RESULTS_FORMAT = ['application/json', 'text/json'].freeze
  def createfile
    tp = test_file_params.merge!(plate_id: params[:plate_id])
    result_file = tp[:computed_results]

    raise unless RESULTS_FORMAT.include? result_file.content_type
    raise if Clamby.virus?(result_file.tempfile.path)

    test_results = JSON.parse(result_file.tempfile.read)
    raise "invalid json format" unless TestResultsModule.validate_results(test_results)

    mapped_results = test_results.each.map do |tr|
      well = @plate.wells.where.not(sample: nil).find_by!(row: tr['row'], column: tr['column'])
      state = tr['state']
      { well_id: well.id, state: TestResult.states[state] }
    end

    params = tp.merge!(test_results_attributes: mapped_results).except(:computed_results)
    @test = Test.new(params)
    authorize Test
    respond_to do |format|
      if @test.save
        @test.plate.complete!
        format.html { redirect_to plate_url(@test.plate), notice: 'Test was successfully created.'}
        format.json { render :show, status: :created, location: test }
      else
        format.html { render :new, status: :unprocessable_entity, alert: "Could not create test"}
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  def confirm
    if @plate.analysed?
      flash[:alert] = "Invalid plate state to confirm"
      redirect_to(request.referrer || plates_tests_path(@plate, @test)) and return
    end

    tp = test_analysis_params.merge!(plate_id: params[:plate_id])
    begin
      @test.transaction do
        @test.update(tp)
        @test.plate.analysed!
        # update all the samples to confirmed status
        @test.plate.samples.update(state: Sample.states[:communicated])
        @test.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Request failed with exception #{e}")
      respond_to do |format|
        flash.now[:alert] = "Could not process plate"
        format.html { render :new }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
      return
    end
    respond_to do |format|
      format.html { redirect_to plate_url(@plate), notice: 'Test was successfully confirmed.' }
      format.json { render :show, status: :created, location: @test }
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_test
    @test = authorize Test.includes(plate: [wells: [sample: [:client]]]).find(params[:id])
  end

  def set_plate
    @plate = Plate.find(params[:plate_id])
  end

  # Only allow a list of trusted parameters through.
  def test_params
    params.fetch(:test, {}).permit(:user_id, :result_file, :comment, :batch, test_results_attributes: [:state, :well_id, :id,:test_id])
  end

  def test_file_params
    params.fetch(:test, {}).permit(:user_id, :result_file, :computed_results)
  end

  def test_analysis_params
    params.fetch(:test, {}).permit(:user_id, :result_file, :comment, :batch, test_results_attributes: [:comment, :state, :well_id, :id,:test_id])
  end
end
