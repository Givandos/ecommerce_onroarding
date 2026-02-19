class CreateCompanySettings < ActiveRecord::Migration[8.1]
  def change
    create_table :company_settings do |t|
      t.references :company, null: false, foreign_key: true
      t.integer :default_lead_time
      t.integer :days_of_stock
      t.integer :forecasting_days
      t.string :integration_type

      t.timestamps
    end
  end
end
