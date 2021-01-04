class ApplicationController < ActionController::Base
  include Pundit
  before_action :set_state_quantities
  before_action :set_raven_context

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def set_state_quantities

    unless request.format.json?
      sample_groups = Sample.group(:state).count
      plate_groups = Plate.group(:state).count 
      @pendingprepare_count = sample_groups[:received.to_s] || 0
      @pendingreadytest_count = plate_groups[Plate.statuses[:preparing]] || 0
      @pendingtest_count = plate_groups[Plate.statuses[:prepared]] || 0
      @pendinganalyze_count = plate_groups[Plate.statuses[:testing]] || 0
      @completed_tests_count = plate_groups[Plate.statuses[:complete]] || 0
      @done_tests_count = plate_groups[Plate.statuses[:analysed]] || 0
    end
  end


  protected
  def wrap_in_current_user
    Sample.with_user(current_user) do
      yield
    end
  end
  private
  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action"
    redirect_to(request.referrer || root_path)
  end
end
