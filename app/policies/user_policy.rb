class UserPolicy < ApplicationPolicy

    def index?
      staffmember?
    end

    def new?
      staffmember?
    end

    def create_staff?
      staffmember?
    end

    def show?
      staffmember? || user == @record
    end

    def edit?
      staffmember? || user == @record
    end

    def update?
      staffmember? || user == @record
    end

    def destroy?
      staffmember? || user == @record
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