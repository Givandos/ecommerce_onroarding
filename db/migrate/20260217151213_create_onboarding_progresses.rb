class CreateOnboardingProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :onboarding_progresses do |t|
      t.references :company, null: false, foreign_key: true
      t.references :current_step, foreign_key: { to_table: :onboarding_steps }
      t.json :completed_steps, default: {}
      t.integer :status, default: 1

      t.timestamps
    end
  end
end
