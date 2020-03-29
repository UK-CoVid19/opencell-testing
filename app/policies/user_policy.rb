class UserPolicy < ApplicationPolicy

    def index?
      user.present? && user.staff?
    end

    def show?
      (user.present? && user.staff?) || user == @record
    end

    def edit?
      user.present? && user.staff? || user == @record
    end

    def update?
      user.present? && user.staff? || user == @record
    end

    def destroy?
      user.present? && user.staff? || user == @record
    end

    class Scope < Scope
      def resolve
        if(user.present? && user.patient?)
          scope.where(user: user)
        elsif (user.present? && user.staff?)
          scope.all
        end
      end
    end
end