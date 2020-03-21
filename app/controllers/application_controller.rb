class ApplicationController < ActionController::Base
  include Pundit
  before_action :set_state_quantities
  before_action :configure_permitted_parameters, if: :devise_controller?


  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :telno, :dob   ])
  end

  def set_state_quantities
    @pendingdispatch_count = Sample.is_requested.size
    @pendingreceive_count = Sample.is_dispatched.size
    @pendingprepare_count = Sample.is_received.size
    @pendingreadytest_count = Sample.is_preparing.size
    @pendingtest_count = Sample.is_prepared.size
    @pendinganalyze_count = Sample.is_tested.size
  end
end
