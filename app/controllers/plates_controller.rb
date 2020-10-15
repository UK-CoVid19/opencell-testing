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
    respond_to do |format|
      format.html
      format.csv { send_data @plate.to_csv, filename: "plate-#{@plate.uid}.csv" }
      format.json
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plate
      @plate = authorize Plate.includes(wells: [:test_result, :sample]).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def plate_params
      params.require(:plate).permit!
    end
end
