class ApplicationController < ActionController::Base
  include Pundit
  before_action :set_state_quantities, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :telno, :dob])
  end

  def set_state_quantities
    @pendingdispatch_count = Sample.is_requested.size
    @pendingreceive_count = Sample.is_dispatched.size
    @pendingprepare_count = Sample.is_received.size
    @pendingreadytest_count = Plate.is_preparing.size
    @pendingtest_count = Plate.is_prepared.size
    @pendinganalyze_count = Plate.is_testing.size
  end

  private
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action"
    redirect_to(request.referrer || root_path)
  end
end
