class PlatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plate, only: [:show, :edit, :update, :destroy]
  around_action :wrap_in_current_user
  after_action :verify_authorized
  # GET /plates
  # GET /plates.json
  def index
    authorize Plate
    @plates = Plate.all
  end
  # GET /plates/1
  # GET /plates/1.json
  def show
  end

  # GET /plates/1/edit
  def edit
  end

  # PATCH/PUT /plates/1
  # PATCH/PUT /plates/1.json
  def update
    respond_to do |format|
      if @plate.update(plate_params)
        format.html { redirect_to @plate, notice: 'Plate was successfully updated.' }
        format.json { render :show, status: :ok, location: @plate }
      else
        format.html { render :edit }
        format.json { render json: @plate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plates/1
  # DELETE /plates/1.json
  def destroy
    @plate.destroy
    respond_to do |format|
      format.html { redirect_to plates_url, notice: 'Plate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plate
      @plate = authorize Plate.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def plate_params
      params.require(:plate).permit!
    end
end
