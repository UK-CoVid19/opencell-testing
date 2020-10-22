class ClientPolicy < ApplicationPolicy

  def new?
    staffmember?
  end

  def create?
    staffmember?
  end

  def samples?
    staffmember?
  end
end
