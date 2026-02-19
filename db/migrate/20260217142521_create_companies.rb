class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.references :industry, null: false, foreign_key: true
      t.string :size
      t.string :location
      t.string :subscription_tier

      t.timestamps
    end
  end
end
