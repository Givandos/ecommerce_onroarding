class CreateIndustries < ActiveRecord::Migration[8.1]
  def change
    create_table :industries do |t|
      t.string :name
    end
  end
end
