class PlatePolicy < ApplicationPolicy
  def index?
    staffmember?
  end

  def show?
    staffmember?
  end

  def edit?
    staffmember?
  end

  def update?
    staffmember?
  end

  def destroy?
    staffmember?
  end
end