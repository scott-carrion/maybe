# frozen_string_literal: true

# JSON builder for budget summary API endpoint
#json.total_spent @income_statement.total_expenses
#json.total_earned @income_statement.total_income
#json.total_budgeted @budget.total_amount

# Overall budget status summary
#json.total_budgeted_spending @budget.budgeted_spending
# XXX: DO WE NEED ABOVE?
json.total_allocated_spending @budget.allocated_spending
json.total_actual_spending @budget.actual_spending
json.total_available_to_spend @budget.available_to_spend
json.total_percent_spent @budget.percent_of_budget_spent
json.total_percent_overage @budget.overage_percent
# XXX: DO WE NEED ABOVE?

# Iterate for all categories in selected budget
json.categories @budget.budget_categories.includes(:category) do |budget_category|
  # Dump name, actual $ spend, $ available, and % budget spent
  json.name budget_category.category.name
  json.spent budget_category.actual_spending
  json.available budget_category.available_to_spend
  json.percent_spent budget_category.percent_of_budget_spent
end
