class CreateWarehouses < ActiveRecord::Migration[8.1]
  def change
    create_table :warehouses do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :location
      t.string :type
      t.string :capacity

      t.timestamps
    end
  end
end
