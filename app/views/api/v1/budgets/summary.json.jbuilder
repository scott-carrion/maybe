# frozen_string_literal: true

#json.accounts @accounts do |account|
#  json.id account.id
#  json.name account.name
#  json.balance account.balance_money.format
#  json.currency account.currency
#  json.classification account.classification
#  json.account_type account.accountable_type.underscore
#end
#
#json.pagination do
#  json.page @pagy.page
#  json.per_page @per_page
#  json.total_count @pagy.count
#  json.total_pages @pagy.pages
#end

#json.total_spent @income_statement.total_expenses
#json.total_earned @income_statement.total_income
#json.total_budgeted @budget.total_amount

# Iterate for all categories in selected budget
json.categories @budget.budget_categories.includes(:category) do |budget_category|
  #next if budget_category.category.income?

  # Dump name, actual $ spend, $ available, and % budget spent
  json.name budget_category.category.name
  json.spent budget_category.actual_spending
  json.available budget_category.available_to_spend
  json.percent_spent budget_category.percent_of_budget_spent
end
