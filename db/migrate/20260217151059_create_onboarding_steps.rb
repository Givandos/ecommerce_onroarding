class CreateOnboardingSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :onboarding_steps do |t|
      t.string :name
      t.string :slug
      t.integer :position
      t.boolean :skippable, default: true
      t.integer :required_step_id
      t.string :required_sync_type

      t.timestamps
    end
  end
end
