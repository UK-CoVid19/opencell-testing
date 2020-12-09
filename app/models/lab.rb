class Lab < ApplicationRecord
  has_and_belongs_to_many :labgroups
  has_many :plates


  def main_labgroup
    return labgroups.first unless labgroups.empty?
    
    raise "No Labgroup for this lab"
  end
end
