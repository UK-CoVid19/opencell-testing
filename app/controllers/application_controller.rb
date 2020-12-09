class ApplicationController < ActionController::Base
  include Pundit
  before_action :set_state_quantities, if: :user_signed_in?
  before_action :set_raven_context

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def after_sign_in_path_for(resource)
    session_labgroup_users_path
  end

  protected

  def verify_labgroup
    return if !user_signed_in?
    unless session[:labgroup] && session[:lab]
      flash[:alert] = "Please set a lab group"
      redirect_to session_labgroup_users_path and return
    end
    @lab = Lab.find(session[:lab])
  end 
  
  def set_state_quantities

    unless request.format.json?
      verify_labgroup
      sample_groups = Sample.by_lab(@lab).group(:state).count
      plate_groups = Plate.by_lab(@lab).group(:state).count
      @pendingprepare_count = sample_groups[:received.to_s] || 0
      @pendingreadytest_count = plate_groups[:preparing.to_s] || 0
      @pendingtest_count = plate_groups[:prepared.to_s] || 0
      @pendinganalyze_count = plate_groups[:testing.to_s] || 0
      @completed_tests_count = plate_groups[:complete.to_s] || 0
      @done_tests_count = plate_groups[:analysed.to_s] || 0
    end
  end

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
