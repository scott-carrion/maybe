# frozen_string_literal: true

# This API endpoint was written by Scott Carrion
# It is intended for integration with Home Assistant and other dashboarding software

class Api::V1::BudgetsController < Api::V1::BaseController

  # Ensure proper scope authorization for read access
  before_action :ensure_read_scope

  # GET /api/v1/budget/summary
  # This API call returns key summary information for the currently active budget
  # The currently active budget is defined as the budget active for the current month
  def summary
    # Find the budget via a Date object
    # https://api.rubyonrails.org/v2.3.8/classes/ActiveSupport/CoreExtensions/Date/Calculations.html
    @budget = Current.family.budgets.find_by(start_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month)

    if @budget.nil?
      render json: { error: "Budget for the current month not found" }, status: :not_found
      return
    end

    # Rails will automatically use app/views/api/v1/budgets/summary.json.jbuilder
    render :summary
  rescue => e
    Rails.logger.error "BudgetsController error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    render json: {
      error: "internal_server_error",
      message: "Error: #{e.message}"
    }, status: :internal_server_error
end

    private

      def ensure_read_scope
        authorize_scope!(:read)
      end
end
