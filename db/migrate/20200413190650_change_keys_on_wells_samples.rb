class ChangeKeysOnWellsSamples < ActiveRecord::Migration[5.2]
  def change
    add_reference :wells, :sample, foreign_key: true, null: true
    Sample.all.each do |s|
      if s.well.present?
        s.well.sample_id = s.id
        s.well.save!
      end
    end
  end
end
