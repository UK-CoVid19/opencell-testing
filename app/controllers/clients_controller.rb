class ClientsController < InheritedResources::Base
  before_action :authenticate_user!
  # after_action :verify_authorized

  def create
    @api_key = SecureRandom.base64(16)
    cp = client_params.merge!(api_key: @api_key)
    @client = authorize Client.new(cp)
    respond_to do |format|
      if @client.save
        format.html { render :client_created, notice: 'Client was successfully created.' }
        format.json { render :show, status: :created, location: @sample }
      else
        format.html { render :new }
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def client_params
    params.require(:client).permit(:name, :notify)
  end
end
