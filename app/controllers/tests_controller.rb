class TestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_test, only: [:show, :edit, :update, :destroy, :analyse, :confirm]
  before_action :set_plate, except: [:complete, :analyse, :done]
  around_action :wrap_in_current_user, only: [:create, :confirm, :update]
  after_action :verify_authorized

  # GET /tests
  # GET /tests.json

  def complete
    authorize Test
    @tests = Test.all.joins(:plate).where(plates: {state: Plate.states[:complete]})
  end

  def done
    authorize Test
    @tests = Test.all.joins(:plate).where(plates: {state: Plate.states[:analysed]})
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

  # GET /tests/1/edit
  def edit
  end

  def analyse
  end 

  # POST /tests
  # POST /tests.json
  def create
    tp = test_params.merge!(plate_id: params[:plate_id])
    @plate.test = Test.new(tp)
    @test = Test.new(tp)
    @test.plate.complete!
    authorize @test
    respond_to do |format|
      if @test.save
        format.html { redirect_to plate_url(@plate), notice: 'Test was successfully created.' }
        format.json { render :show, status: :created, location: @test }
      else
        format.html { render :new, status: :unprocessable_entity  }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  def confirm
    tp = test_analysis_params.merge!(plate_id: params[:plate_id])
    @test.update(tp)
    @test.plate.analysed!
    # update all the samples to confirmed status
    @test.plate.samples.update(state: Sample.states[:communicated])
    respond_to do |format|
      if @test.save
        format.html { redirect_to plate_url(@plate), notice: 'Test was successfully confirmed.' }
        format.json { render :show, status: :created, location: @test }
      else
        format.html { render :new }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tests/1
  # PATCH/PUT /tests/1.json
  def update
    tp = test_params.merge!(plate_id: params[:plate_id])
    respond_to do |format|
      if @test.update(tp)
        format.html { redirect_to [@plate, @test], notice: 'Test was successfully updated.' }
        format.json { render :show, status: :ok, location: @test }
      else
        format.html { render :edit }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tests/1
  # DELETE /tests/1.json
  def destroy
    @test.destroy
    respond_to do |format|
      format.html { redirect_to tests_url, notice: 'Test was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test
      @test = authorize Test.find(params[:id])
    end

    def set_plate
      @plate = Plate.find(params[:plate_id])
    end

    # Only allow a list of trusted parameters through.
    def test_params
      params.fetch(:test, {}).permit(:user_id, result_files: [] , test_results_attributes: [:value, :well_id, :id,:test_id])
    end

    def test_analysis_params
      params.fetch(:test, {}).permit(:user_id, result_files: [] , test_results_attributes: [:comment, :state, :well_id, :id,:test_id])
    end
end
