module Api
  module V1
    class OnboardingController < ApplicationController
      before_action :set_company # we use this method instead of authentication for the demo purpose

      # GET /api/v1/onboarding/status
      def status
        onboarding_status_service = OnboardingStatusService.new(@company)
        onboarding_status_service.call

        render json: onboarding_status_service.status_data
      end

      # PATCH /api/v1/onboarding/steps/:slug
      def update_step
        progress_service = UpdateProgressService.new(company: @company, slug: params[:slug], params: permitted_params)
        progress_service.call

        if progress_service.error
          return render json: { error: progress_service.error }, status: :locked
        end

        progress = progress_service.progress

        render json: {
          message: "Step updated successfully",
          current_step: progress.current_step ? {
            id: progress.current_step.id,
            name: progress.current_step.name,
            slug: progress.current_step.slug
          } : nil,
          overall_status: progress.status
        }
      end

      # GET /api/v1/onboarding/sync_progress
      def sync_progress
        sync_service = SyncStatusService.new(@company)

        render json: sync_service.all_progress
      end

      private

      def set_company
        # In a real app, this would come from authentication
        # For now, we'll use the first company
        @company = Company.first
      end

      def permitted_params
        # Allow any params because we don't have strict requirements yet
        params.fetch(:step_params, ActionController::Parameters.new).permit!
      end
    end
  end
end
