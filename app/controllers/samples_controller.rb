class SamplesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sample, only: [:show, :edit, :update, :destroy, :receive, :prepare]
  after_action :verify_policy_scoped, only: [:index]
  # GET /samples
  # GET /samples.json
  def index
    @samples = policy_scope(Sample.all)
  end

  def pendingdispatch
    @samples = Sample.all.where(state: Sample.states[:requested])
  end

  def pendingreceive
    @samples = Sample.all.where(state: Sample.states[:dispatched])
  end

  def pendingprepare
    @samples = Sample.all.where(state: Sample.states[:received])
  end


  def pendingtest
    @samples = Sample.all.where(state: Sample.states[:processed])
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

  # def dispatch
  # end
  #
  def receive
    @sample.state = Sample.states[:received]
    respond_to do |format|
      if @sample.save
        format.html { redirect_to @sample, notice: 'Sample was successfully received.' }
        format.json { render :show, status: :created, location: @sample }
      else
        format.html { render :new }
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end
  #
  def prepare
    @sample.state = Sample.states[:preparing]
    respond_to do |format|
      if @sample.save
        format.html { redirect_to @sample, notice: 'Sample was successfully received.' }
        format.json { render :show, status: :created, location: @sample }
      else
        format.html { render :new }
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end
  #
  # def process
  # end
  #
  # def analyse
  # end


  # POST /samples
  # POST /samples.json
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
    # Use callbacks to share common setup or constraints between actions.
    def set_sample
      @sample = Sample.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sample_params
      params.require(:sample).permit(:user_id, :state)
    end
end
