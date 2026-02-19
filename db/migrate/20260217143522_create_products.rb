class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :sku
      t.decimal :cost
      t.decimal :price
      t.integer :lead_time
      t.references :category, null: false, foreign_key: true
      t.references :supplier, foreign_key: { to_table: :vendors }

      t.timestamps
    end
  end
end
