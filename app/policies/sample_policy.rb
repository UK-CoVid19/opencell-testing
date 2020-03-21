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

  def dashboard?
    user.present? && user.staff?
  end
end