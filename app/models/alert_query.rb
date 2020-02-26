class AlertQuery < Query
  self.queried_class = Alert
  self.view_permission = :view_alerts

  self.available_columns = [
      QueryColumn.new(:id, :sortable => "#{Alert.table_name}.id", :default_order => 'desc', :caption => '#', :frozen => true),
      QueryColumn.new(:begin_time, :sortable => "#{Alert.table_name}.begin_time", :default_order => 'desc', :caption => :label_alert_begin_date),
      QueryColumn.new(:end_time, :sortable => "#{Alert.table_name}.end_time", :default_order => 'desc', :caption => :label_alert_end_date),
      QueryColumn.new( :issue, :sortable => "#{Issue.table_name}.subject"),
      QueryColumn.new(:project, :sortable => "#{Project.table_name}.name", :groupable => true),
      QueryColumn.new(:tracker, :sortable => "#{Tracker.table_name}.position", :groupable => true),
      QueryColumn.new(:status, :sortable => "#{IssueStatus.table_name}.position", :groupable => true),
      QueryColumn.new(:priority, :sortable => "#{IssuePriority.table_name}.position", :default_order => 'desc', :groupable => true),
      QueryColumn.new(:subject, :sortable => "#{Issue.table_name}.subject"),
      QueryColumn.new(:author, :sortable => lambda {User.fields_for_order_statement("authors")}, :groupable => true),
      QueryColumn.new(:assigned_to, :sortable => lambda {User.fields_for_order_statement}, :groupable => true),
      QueryColumn.new(:updated_on, :sortable => "#{Issue.table_name}.updated_on", :default_order => 'desc'),
      QueryColumn.new(:category, :sortable => "#{IssueCategory.table_name}.name", :groupable => true),
      QueryColumn.new(:description, :inline => false),
      # QueryColumn.new(:fixed_version, :sortable => lambda {Version.fields_for_order_statement}, :groupable => true),
      QueryColumn.new(:start_date, :sortable => "#{Issue.table_name}.start_date"),
      QueryColumn.new(:due_date, :sortable => "#{Issue.table_name}.due_date"),
      QueryColumn.new(:estimated_hours, :sortable => "#{Issue.table_name}.estimated_hours", :totalable => true),
      QueryColumn.new(:done_ratio, :sortable => "#{Issue.table_name}.done_ratio", :groupable => true),
      QueryColumn.new(:created_on, :sortable => "#{Issue.table_name}.created_on", :default_order => 'desc'),
      QueryColumn.new(:closed_on, :sortable => "#{Issue.table_name}.closed_on", :default_order => 'desc')
  ]

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= { 'issue_id' => {:operator => "*", :values => [""]} }
  end

  def available_columns
    return @available_columns if @available_columns
    @available_columns = self.class.available_columns.dup
    @available_columns
  end

  def initialize_available_filters
    add_available_filter("begin_time",
                         :type => :date)

    add_available_filter("end_time",
                         :type => :date)

    add_available_filter "status_id",
                         :type => :list_status, :values => lambda { issue_statuses_values }

    add_available_filter("project_id",
                         :type => :list, :values => lambda { project_values }
    ) if project.nil?

    add_available_filter "tracker_id",
                         :type => :list, :values => trackers.collect{|s| [s.name, s.id.to_s] }

    add_available_filter "priority_id",
                         :type => :list, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] }

    add_available_filter("author_id",
                         :type => :list, :values => lambda { author_values }
    )

    add_available_filter("assigned_to_id",
                         :type => :list_optional, :values => lambda { assigned_to_values }
    )

    add_available_filter "category_id",
                         :type => :list_optional,
                         :values => lambda { project.issue_categories.collect{|s| [s.name, s.id.to_s] } } if project

    # add_available_filter "fixed_version_id",
    #                      :type => :list_optional, :values => lambda { fixed_version_values }

    add_available_filter "subject", :type => :text
    add_available_filter "description", :type => :text
    add_available_filter "created_on", :type => :date_past
    add_available_filter "updated_on", :type => :date_past
    add_available_filter "closed_on", :type => :date_past
    add_available_filter "start_date", :type => :date
    add_available_filter "due_date", :type => :date
    add_available_filter "estimated_hours", :type => :float
    add_available_filter "done_ratio", :type => :integer

  end

  def default_columns_names
    @default_columns_names = [:id, :project, :issue, :begin_time, :end_time]
  end

  def default_sort_criteria
    [['id', 'desc']]
  end

  def alerts(options={})
    order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)
    scope = Alert.visible.
        includes(:issue=> [:status, :project, :assigned_to, :author, :priority]).
        where(statement).
        order(order_option).
        limit(options[:limit]).
        offset(options[:offset])

    alerts = scope.to_a
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  def base_scope
    Alert.visible.
        includes(:issue=> [:status, :project])
  end

  def alerts_count
    base_scope.count
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  def sql_for_project_id_field(field, operator, value)
    sql = "(issue_id IN ( SELECT #{Issue.table_name}.id FROM #{Issue.table_name} WHERE "
    sql << sql_for_field(field, operator, value, Issue.table_name, 'project_id')
    sql << ') )'
    sql
  end

  def sql_for_done_ratio_field(field, operator, value)
    sql = "(issue_id IN ( SELECT #{Issue.table_name}.id FROM #{Issue.table_name} WHERE "
    sql << sql_for_field(field, operator, value, Issue.table_name, 'done_ratio')
    sql << ') )'
    sql
  end

  def sql_for_author_id_field(field, operator, value)
    sql = "(issue_id IN ( SELECT #{Issue.table_name}.id FROM #{Issue.table_name} WHERE "
    sql << sql_for_field(field, operator, value, Issue.table_name, 'author_id')
    sql << ') )'
    sql
  end

  private

  def requester_values
    requester_values = []
    requester_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
    users = User.all
    requester_values += users.sort_by(&:name).collect{|s| s.name }
    requester_values
  end

end