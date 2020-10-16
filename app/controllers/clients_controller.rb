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

  def stats
    @stats = resource.stats
    respond_to do |format|
      format.html
      format.csv { send_data create_stats_csv(@stats.to_a), filename: "stats-client-#{resource.id}.csv" }
      format.json
    end
  end

  def testhook
    success = resource.test_webhook
    if success
      head :ok
    else
      head :bad_request
    end
  end

  private

  def client_params
    params.require(:client).permit(:name, :notify, :url, headers_attributes: [:id, :key, :value, :_destroy])
  end

  def create_stats_csv(stats)
    headers = %w{date requested tested rerun rejected internalchecks}
    CSV.generate(headers: true) do |csv|
      csv << headers
      stats.each do | stat |
        csv << [stat.date, stat.requested, stat.communicated, stat.reruns, stat.rejects, stat.internalchecks]
      end
    end
  end
end
