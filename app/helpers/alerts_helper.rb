module AlertsHelper
  include ApplicationHelper

  def grouped_alerts_list(alerts, query, &block)
    ancestors = []
    grouped_query_results(alerts, query) do |alert, group_name, group_count, group_totals|
      yield alert, ancestors.size, group_name, group_count, group_totals
      ancestors << alert
    end
  end

end
