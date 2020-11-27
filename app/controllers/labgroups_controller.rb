class LabgroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_labgroup, only: [:show, :edit, :update, :destroy]

  # GET /labgroups
  # GET /labgroups.json
  def index
    @labgroups = Labgroup.all
  end

  # GET /labgroups/1
  # GET /labgroups/1.json
  def show
  end

  # GET /labgroups/new
  def new
    @labgroup = Labgroup.new
  end

  # GET /labgroups/1/edit
  def edit
  end

  # POST /labgroups
  # POST /labgroups.json
  def create
    @labgroup = Labgroup.new(labgroup_params)

    respond_to do |format|
      if @labgroup.save
        format.html { redirect_to @labgroup, notice: 'Labgroup was successfully created.' }
        format.json { render :show, status: :created, location: @labgroup }
      else
        format.html { render :new }
        format.json { render json: @labgroup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /labgroups/1
  # PATCH/PUT /labgroups/1.json
  def update
    respond_to do |format|
      if @labgroup.update(labgroup_params)
        format.html { redirect_to @labgroup, notice: 'Labgroup was successfully updated.' }
        format.json { render :show, status: :ok, location: @labgroup }
      else
        format.html { render :edit }
        format.json { render json: @labgroup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /labgroups/1
  # DELETE /labgroups/1.json
  def destroy
    @labgroup.destroy
    respond_to do |format|
      format.html { redirect_to labgroups_url, notice: 'Labgroup was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_labgroup
      @labgroup = Labgroup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def labgroup_params
      params.require(:labgroup).permit(:name, lab_ids:[], user_ids: [], client_ids: [])
    end
end
