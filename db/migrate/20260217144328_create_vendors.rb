class CreateVendors < ActiveRecord::Migration[8.1]
  def change
    create_table :vendors do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :country
      t.string :avg_lead_time
      t.string :reliability_score

      t.timestamps
    end
  end
end
