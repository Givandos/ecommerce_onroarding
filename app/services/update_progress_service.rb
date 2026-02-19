class UpdateProgressService
  STEP_HANDLERS = {
    welcome: :welcome,
    lead_time: :set_lead_time,
    days_of_stock: :set_days_of_stock,
    forecasting: :set_forecasting,
    po_upload: :po_upload,
    suppliers_match: :suppliers_match,
    bundles: :bundles,
    integrations: :integrations
  }.freeze

  attr_reader :error, :progress
  def initialize(company:, slug:, params:)
    @slug = slug.to_sym
    @step = OnboardingStep.find_by!(slug: @slug)
    @company = company
    @params = params
    @progress = company.onboarding_progress
    @sync_service = SyncStatusService.new(company)
  end

  def call
    check_step_locking
    return if @error

    handle_step
    return if @error

    complete_step unless ActiveModel::Type::Boolean.new.cast(@params[:skip_step]) == true
    move_next
  end

  private

  def check_step_locking
    if is_locked?(@step)
      @error = "Step is locked. You can't proceed until it's unlocked."
    end
  end

  def handle_step
    step_handler = STEP_HANDLERS[@slug]
    if step_handler
      send(step_handler)
    else
      @error = "Step has not been implemented yet."
    end
  end

  def complete_step
    @progress.complete_step!(@slug)
  end

  def skip_step
    @progress.skip_step!(@slug)
  end

  def move_next
    if next_step
      @progress.move_to_step!(next_step) unless next_step_is_locked?
    else
      @progress.completed!
    end
  end

  def next_step_is_locked?
    return false unless next_step

    @next_step_is_locked ||= is_locked?(next_step)
  end

  def next_step
    return @next_step if @next_step

    completed_steps = @progress.completed_steps.keys
    @next_step = OnboardingStep.where("position > ?", @step.position)
                                 .where.not(slug: completed_steps)
                                 .order(:position)
                                 .first
  end

  def welcome
    # Some initial AI setups if it's required
  end

  def set_lead_time
    if @params[:default_lead_time]
      # This part can use DB transaction if it's required to be atomic.
      # But for demo purposes we'll just update the setting directly
      company_setting = @company.company_setting
      company_setting.update(default_lead_time: @params[:default_lead_time])
      if company_setting.errors.any?
        @error = company_setting.errors.full_messages.join(", ")
      else
        LeadTimeUpdater.perform_async(@company.id)
      end
    else
      @error = "Default lead time is required for this step."
    end
  end

  def set_days_of_stock
    if @params[:days_of_stock]
      # This part can use DB transaction if it's required to be atomic.
      # But for demo purposes we'll just update the setting directly
      company_setting = @company.company_setting
      company_setting.update(default_lead_time: @params[:days_of_stock])
      if company_setting.errors.any?
        @error = company_setting.errors.full_messages.join(", ")
      else
        # On my opinion days_of_stock should trigger calculations as forecasting_days
        RefreshCalculationsWorker.perform_async(@company.id)
      end
    else
      @error = "Days of stock is required for this step."
    end
  end

  def set_forecasting
    if @params[:forecasting_days]
      # This part can use DB transaction if it's required to be atomic.
      # But for demo purposes we'll just update the setting directly
      company_setting = @company.company_setting
      company_setting.update(default_lead_time: @params[:forecasting_days])
      if company_setting.errors.any?
        @error = company_setting.errors.full_messages.join(", ")
      else
        RefreshCalculationsWorker.perform_async(@company.id)
      end
    else
      @error = "Forecasting days is required for this step."
    end
  end

  def po_upload
    # Accept @params[:po_upload_file] as a file object for demo purposes
    if @params[:po_upload_file]
      # Handle POs file upload logic here
      # We can use background jobs for this if we don't want to block the UI
    elsif ActiveModel::Type::Boolean.new.cast(@params[:skip_step]) == true
      if @step.skippable?
        skip_step
      else
        @error = "You can't skip this step."
      end
    else
      @error = "You should upload a file or choose skip option for this step."
    end
  end

  def suppliers_match
    if @params[:copy_vendors_to_suppliers] == true
      # Logic to copy vendors to suppliers here
    elsif ActiveModel::Type::Boolean.new.cast(@params[:skip_step]) == true
      if @step.skippable?
        skip_step
      else
        @error = "You can't skip this step."
      end
    else
      @error = "You should select an option or choose skip option for this step."
    end
  end

  def bundles
    # Accept @params[:bundles_file] as a file object for demo purposes
    if @params[:bundles_file]
      # Handle bundles file upload logic here
      # We can use background jobs for this if we don't want to block the UI
    elsif ActiveModel::Type::Boolean.new.cast(@params[:skip_step]) == true
      if @step.skippable?
        skip_step
      else
        @error = "You can't skip this step."
      end
    else
      @error = "You should upload a file or choose skip option for this step."
    end
  end

  def integrations
    # Handle external integration setup here
    @company.company_setting.update!(integration_type: @params[:integration_type])
  end

  def is_locked?(step)
    locked_by_sync?(step) || locked_by_step?(step)
  end

  def locked_by_sync?(step)
    return false if step.required_sync_type.blank?

    @sync_service.progress_for(step.required_sync_type) < 100
  end

  def locked_by_step?(step)
    return false if step.required_step_id.blank?

    required_step_slug = OnboardingStep.find_by(id: step.required_step_id)&.slug
    return false unless required_step_slug

    !(@progress.completed_step?(required_step_slug) || @progress.skipped_step?(required_step_slug))
  end
end
