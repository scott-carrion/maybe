# frozen_string_literal: true

# JSON builder for budget summary API endpoint
# Overall budget status summary
# Allocated (budgeted) spending, in chosen currency
json.total_allocated_spending @budget.allocated_spending.to_s

# How much money was actually spent, in chosen currency
json.total_actual_spending @budget.actual_spending.to_s

# How much money is available to spend, in chosen currency
json.total_available_to_spend @budget.available_to_spend.to_s

# Percent of budget funds spent for the month
json.total_percent_spent @budget.percent_of_budget_spent.to_s

# Percent over budget for the month
json.total_percent_overage @budget.overage_percent.to_s

# Iterate for all categories in selected budget
json.categories @budget.budget_categories.includes(:category) do |budget_category|
  # Dump name, actual $ spend, $ available, and % budget spent
  # Name of category
  json.name budget_category.category.name.to_s

  # How much money has been spent for this category, in chosen currency
  json.spent budget_category.actual_spending.to_s

  # How much money is available to spend for this category, in chosen currency
  json.available budget_category.available_to_spend.to_s

  # Percent of category funds spent for the month
  # Unlike the total budget, there is no "percent overage" accessor
  json.percent_spent budget_category.percent_of_budget_spent.to_s
end
