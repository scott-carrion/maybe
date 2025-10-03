# frozen_string_literal: true

class Api::V1::BudgetsController < Api::V1::BaseController

  # Ensure proper scope authorization for read access
  before_action :ensure_read_scope

  # Fetch current period (monthly budget) for query
  before_action :set_period

  # GET /api/v1/budget/summary
  def summary
    puts "XXX SCC DEBUG: CONTROL ENTERED summary"
    #@budget = Current.family.budgets.find_by(month: @period.month, year: @period.year)
    #@budget = Current.family.budgets.find_by(start_date: "10-01-2025")
    @budget = Current.family.budgets.find_by(start_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month)
    #@income_statement = IncomeStatement.new(family: Current.family, period: @period)
    puts "XXX SCC DEBUG: GOT CURRENT BUDGET OK"

    if @budget.nil?
      puts "XXX SCC ERROR: BUDGET WAS NIL"
      render json: { error: "Budget for the current month not found" }, status: :not_found
    end

    # Rails will automatically use app/views/api/v1/budgets/summary.json.jbuilder
    puts "XXX SCC DEBUG NOW RENDERING JSON RESPONSE"
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
        puts "XXX SCC DEBUG: CONTROL ENTERED ensure_read_scope"
        authorize_scope!(:read)
      end

      def set_period
        puts "XXX SCC DEBUG: CONTROL ENTERED set_period"
        #@period = Period.new(Time.current.in_time_zone(Current.family.timezone))

        # Get the current time in the family's specific timezone
        puts "XXX SCC DEBUG: Getting specific timezone"
        time_in_family_zone = Time.current.in_time_zone(Current.family.timezone)
        puts "XXX SCC DEBUG: time_in_family_zone is: #{time_in_family_zone}" 

        # Extract current year and month
        puts "XXX SCC DEBUG: Getting current month and year"
        @current_month = time_in_family_zone.strftime("%m") 
        @current_year = time_in_family_zone.strftime("%Y") 
        puts "XXX SCC DEBUG: Current month and year is: #{@current_month} / #{@current_year}" 

      end
end
