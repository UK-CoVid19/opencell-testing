class TestPolicy < ApplicationPolicy


  def index?
    staffmember?
  end

  def new?
    staffmember?
  end

  def show?
    staffmember?
  end
  
  def create?
    staffmember?
  end

  def createfile?
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

  def complete?
    staffmember?
  end

  def analyse?
    staffmember?
  end

  def confirm?
    staffmember?
  end

  def done? 
    staffmember?
  end
end
