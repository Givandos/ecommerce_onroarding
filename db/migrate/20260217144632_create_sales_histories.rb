class CreateSalesHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :sales_histories do |t|
      t.references :company, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :quantity
      t.decimal :sales_price
      t.date :date

      t.timestamps
    end
  end
end
