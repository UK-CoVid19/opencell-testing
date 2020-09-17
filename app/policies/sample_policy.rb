class SamplePolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if(user.present? && user.patient?)
        scope.where(user: user)
      elsif (user.present? && user.staff?)
        scope.all
      end
    end
  end
  def index?
    staffmember?
  end

  def step3_pendingprepare?
    staffmember?
  end

  def pending_plate?
    staffmember?
  end

  def step4_pendingreadytest?
    staffmember?
  end

  def step5_pendingtest?
    staffmember?
  end

  def step6_pendinganalyze?
    staffmember?
  end

  def show?
    staffmember?
  end

  def new?
    staffmember?
  end

  def edit?
    staffmember?
  end

  def create?
    staffmember?
  end

  def update?
    staffmember?
  end

  def destroy?
    staffmember?
  end

  def step3_bulkprepared?
    staffmember?
  end

  def step4_bulkreadytest?
    staffmember?
  end

  def step5_bulktested?
    staffmember?
  end

  def step6_bulkanalysed?
    staffmember?
  end

  def dashboard?
    staffmember?
  end

end