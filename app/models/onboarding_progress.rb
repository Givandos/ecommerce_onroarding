class OnboardingProgress < ApplicationRecord
  enum :status, {not_started: 1, in_progress: 2, completed: 3}

  belongs_to :company
  belongs_to :current_step, class_name: "OnboardingStep", optional: true

  validates :status, presence: true

  def completed_step?(slug)
    completed_steps[slug] == "completed"
  end

  def skipped_step?(slug)
    completed_steps[slug] == "skipped"
  end

  def complete_step!(slug)
    all_completed_steps = self.completed_steps || {}
    self.completed_steps = all_completed_steps.merge(slug => :completed)
    save!
  end

  def skip_step!(slug)
    all_completed_steps = self.completed_steps || {}
    self.completed_steps = all_completed_steps.merge(slug => :skipped)
    save!
  end

  def move_to_step!(step)
    update!(current_step: step, status: :in_progress)
  end
end
