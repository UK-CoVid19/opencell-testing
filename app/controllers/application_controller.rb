class ApplicationController < ActionController::Base
  include Pundit
  before_action :set_state_quantities

  private
  def set_state_quantities
    @pendingdispatch_count = Sample.requested.size
    @pendingreceive_count = Sample.dispatched.size
    @pendingprepare_count = Sample.received.size
    @pendingreadytest_count = Sample.preparing.size
    @pendingtest_count = Sample.prepared.size
    @pendinganalyze_count = Sample.tested.size
  end
end
