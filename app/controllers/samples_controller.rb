
class SamplesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sample, only: [:show, :edit, :update, :destroy, :receive, :prepare, :prepared, :ship, :tested, :analyze]
  after_action :verify_policy_scoped, only: [:index]
  # GET /samples
  # GET /samples.json
  def index
    @samples = policy_scope(Sample.all)
  end

  def step1_pendingdispatch
    @samples = Sample.is_requested
  end

  def step2_pendingreceive
    @samples = Sample.is_dispatched
  end

  def step3_pendingprepare
    @samples = Sample.is_received
  end

  def step4_pendingreadytest
    @samples = Sample.is_preparing
  end

  def step5_pendingtest
    @samples = Sample.is_prepared
  end

  def step6_pendinganalyze
    @samples = Sample.is_tested
  end
  # GET /samples/1
  # GET /samples/1.json
  def show    
  end

  # GET /samples/new
  def new
    @sample = Sample.new
  end

  # GET /samples/1/edit
  def edit
  end

  def dashboard
    authorize nil, policy_class: SamplePolicy
    @samples = Sample.all
  end


  def create
    @sample = Sample.new(user: current_user, state: Sample.states[:requested])

    respond_to do |format|
      if @sample.save
        format.html { redirect_to @sample, notice: 'Sample was successfully created.' }
        format.json { render :show, status: :created, location: @sample }
      else
        format.html { render :new }
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end

  def step1_bulkdispatched
    bulk_action(Sample.states[:dispatched], step2_pendingreceive_path)
  end

  def step2_bulkreceived
    bulk_action(Sample.states[:received], step3_pendingprepare_path)
  end

  def step3_bulkprepared
    # binding.pry
    get_plated_samples
    respond_to do |format|
      format.html { redirect_to step4_pendingreadytest_path, notice: "Samples have been successfully plated" }
    end
    # bulk_action(Sample.states[:preparing], step4_pendingreadytest_path)
  end

  def step4_bulkreadytest
    bulk_action(Sample.states[:prepared], step5_pendingtest_path)
  end

  def step5_bulktested
    bulk_action(Sample.states[:tested], step6_pendinganalyze_path)
  end

  def step6_bulkanalysed
    bulk_action(Sample.states[:analysed], home_index_path)
  end

  # PATCH/PUT /samples/1
  # PATCH/PUT /samples/1.json
  def update
    respond_to do |format|
      if @sample.update(sample_params)
        format.html { redirect_to @sample, notice: 'Sample was successfully updated.' }
        format.json { render :show, status: :ok, location: @sample }
      else
        format.html { render :edit }
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /samples/1
  # DELETE /samples/1.json
  def destroy
    @sample.destroy
    respond_to do |format|
      format.html { redirect_to samples_url, notice: 'Sample was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def bulk_action(desired_state, redirect_path)
    @samples = get_samples
    Sample.transaction do
      @samples.each do |sample_hash|
        sample_hash[:sample].state = desired_state
        sample_hash[:sample].records << Record.new({user: current_user, note: sample_hash[:note], state: desired_state})
        sample_hash[:sample].save!
      end
    end
    respond_to do |format|
      format.html { redirect_to redirect_path, notice: "Samples have been successfully #{Sample.states.to_hash.key(desired_state).capitalize}." }
    end
  end


  def plate_samples
    @plated_samples = get_plated_samples
  end

  def set_sample
    @sample = Sample.find(params[:id])
  end

    # Only allow a list of trusted parameters through.
  def sample_params
    params.require(:sample).permit(:user_id, :state, :note)
  end


  def get_plated_samples
    params.permit(:wells).each do |s|
      s.permit(:id, :row, :col)
    end
    entries = params.dig(:wells)

    if entries
      valid_samples = entries.select {|e| !(e[:id].blank? || e[:row].blank? || e[:col].blank?)}
      wells = valid_samples.map {|et| {sample: Sample.find(et[:id]), row: et[:row], col: et[:col]}}
      Plate.transaction do
        plate = Plate.create!
        PlateHelper.rows.each do |row|
          PlateHelper.columns.each do |column|
            puts row
            puts column
            new_well = Well.create!(row: row, column: column, plate: plate)
            # if( wells.find {|well| well[:col] == column and well[:row] == row})
            matching_well = wells.find { |w| w[:col] == column.to_s && w[:row] == row}
            puts matching_well
            if(matching_well)
              puts 'matched!!'
              matching_well[:sample].well = new_well
              matching_well[:sample].records << Record.new({user: current_user, note: nil, state: Sample.states[:preparing]})
              matching_well[:sample].state = Sample.states[:preparing]
              matching_well[:sample].save!
            end
          end
        end
      end
    else
      raise
    end

  end

  def get_samples
    params.permit(:samples).each do |s|
      s.permit(:id, :note)
    end
    entries = params.dig(:samples)
    if entries
      @samples = entries.select {|e| !(e[:id].nil? || e[:note].nil?)}.map {|id| {sample: Sample.find(id[:id]), note: id[:note]}}
    else
      []
    end
  end
end
