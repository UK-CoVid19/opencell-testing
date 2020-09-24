class AddRetestIdToSample < ActiveRecord::Migration[6.0]
  def change
    create_table :reruns do |t|
      t.references :sample, foreign_key: true, index: { unique: true }
      t.bigint :retest_id, foreign_key: { to_table: :samples }, index: { unique: true }
      t.string :reason
      t.timestamps
    end
  end
end
