class ClientPolicy < ApplicationPolicy

    def new?
      staffmember?
    end 
    
    def create?
      staffmember?
    end
end