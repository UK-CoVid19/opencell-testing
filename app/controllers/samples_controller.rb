class SamplesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sample, only: [:show, :edit, :destroy, :receive, :prepare, :prepared, :ship, :tested, :analyze]
  around_action :wrap_in_current_user
  after_action :verify_policy_scoped, only: [:index, :step3_pendingprepare, :pending_plate]
  after_action :verify_authorized
  # GET /samples
  # GET /samples.json
  def index
    @samples = policy_scope(Sample.all)
    authorize Sample
  end

  def pending_plate
    @samples = policy_scope(Sample.is_received)
    authorize Sample
  end

  def step3_pendingprepare
    @plate = Plate.build_plate
    @samples = policy_scope(Sample.is_received)
    authorize Sample
  end

  def step4_pendingreadytest
    @plates = Plate.all.where(state: Plate.states[:preparing]).order(:updated_at)
    authorize Sample
  end

  def step5_pendingtest
    @plates = Plate.all.where(state: Plate.states[:prepared]).order(:updated_at)
    authorize Sample
  end

  def step6_pendinganalyze
    @plates = Plate.all.where(state: Plate.states[:testing]).order(:updated_at)
    authorize Sample
  end
  # GET /samples/1
  # GET /samples/1.json
  def show
    authorize Sample
  end

  # GET /samples/new
  def new
    @sample = Sample.new
    authorize @sample
  end

  def dashboard
    authorize Sample
    @samples = Sample.includes(:client).all
    @tested_last_week = Sample.tested_last_week
    @requested_last_week = Sample.requested_last_week
    @failure_rate_last_week = Sample.failure_rate_last_week
    @total_tests = Sample.total_tests
  end

  # DELETE /samples/1
  # DELETE /samples/1.json
  def destroy
    authorize @sample
    @sample.destroy
    respond_to do |format|
      format.html { redirect_to samples_url, notice: 'Sample was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def create
    @sample = authorize Sample.new(sample_params.merge!(state: Sample.states[:received]))
    respond_to do |format|
      if @sample.save
        format.html { redirect_to client_path(@sample.client), notice: 'Sample was successfully created.' }
        format.json { render :show, status: :created, location: @sample }
      else
        format.html { render :new }
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end

  def step3_bulkprepared
    authorize Sample
    plate_params = get_bulk_plate
    Plate.transaction do
      @plate = Plate.new(plate_params).assign_samples(get_mappings)
      respond_to do |format|
        if @plate.save
          format.html { redirect_to step4_pendingreadytest_path, notice: "Samples have been successfully plated" }
          format.json { render :show, status: :created, location: @plate }
        else
          format.html { redirect_to step3_pendingprepare_path, status: :unprocessable_entity, alert: "Could not process plate" }
          format.json { render json: @plate.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def step4_bulkreadytest
    authorize Sample
    plates = get_plates
    if plates.nil? || !plates.any?
      respond_to do |format|
        format.html { redirect_to request.referrer, alert: "No Plates Selected" }
      end
      return
    end
    update_plate(plates)
    respond_to do |format|
      format.html { redirect_to step5_pendingtest_path, notice: "Plate to qPCR" }
    end
  end

  def step5_bulktested
    authorize Sample
    plates = get_plates
    run_plates_test(plates)
    respond_to do |format|
      format.html { redirect_to step6_pendinganalyze_path, notice: "Plate tested" }
    end
  end

  def step6_bulkanalysed
    authorize Sample
    bulk_action(Sample.states[:analysed], home_index_path)
  end

  private
  def update_plate(plates)
    Plate.transaction do
      plates.each do |plate|
        plate.prepared!
        plate.wells.each do |well|
          unless well.sample.nil?
            well.sample.tap do |s|
              s.prepared!
              s.save!
            end
          end
        end
        plate.save!
      end
    end
  end

  def run_plates_test(plates)
    Plate.transaction do
      plates.each do |plate|
        plate.testing!
        plate.wells.each do | well|
          unless well.sample.nil?
            well.sample.tap do |s|
              s.tested!
              s.save!
            end
          end
        end
        plate.save!
      end
    end
  end

  def bulk_action(desired_state, redirect_path)
    @samples = get_samples
    unless @samples.any?
      respond_to do |format|
        format.html { redirect_to request.referrer, alert: "No Samples Selected" }
      end
      return
    end
    begin
      Sample.transaction do
        @samples.each do |sample_hash|
          sample_hash[:sample].state = desired_state
          sample_hash[:sample].save!
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.html { redirect request.referrer, alert: e.message, status: :unprocessable_entity }
        format.json { render json: e.errors, status: :unprocessable_entity }
      end
      return
    end
    respond_to do |format|
      format.html { redirect_to redirect_path, notice: "Samples have been successfully #{Sample.states.to_hash.key(desired_state).capitalize}." }
    end
  end

  def set_sample
    @sample = authorize Sample.find(params[:id])
  end

    # Only allow a list of trusted parameters through.
  def sample_params
    params.require(:sample).permit(:client_id, :state)
  end

  def get_samples
    params.permit(:samples).each do |s|
      s.permit(:id)
    end
    entries = params.dig(:samples)
    if entries
      @samples = entries.select {|e| !(e[:id].nil?)}.map {|id| {sample: Sample.find(id[:id])}}
    else
      []
    end
  end

  def get_plates
    params.permit(:plates).each do |s|
      s.permit(:id)
    end
    plates = params.dig(:plates)
    return nil unless plates&.any?

    return plates.map {|plate| Plate.find(plate[:id])}

  end

  def get_bulk_plate
    params.require(:plate).permit(wells_attributes:[:id, :row, :column ])
  end
  def get_mappings
    params.require(:sample_well_mapping).permit(mappings:[:id,:row, :column, :control, :control_code])[:mappings]
  end

end
