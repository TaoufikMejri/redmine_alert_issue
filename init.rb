require_dependency 'redmine_alert_issue/hooks'
require_dependency 'redmine_alert_issue/queries_controller_patch'

Redmine::Plugin.register :redmine_alert_issue do
  name 'Redmine Alert Issue plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  permission :alerts, alerts: :index

  menu :application_menu, :alerts, { :controller => 'alerts', :action => 'index' }, :after => :issues

  menu :top_menu, :alert_notifications, { :controller => 'alerts', :action => 'notifications' }, {
      :caption => :label_notifications,
      :last => true,
      :if => Proc.new { User.current.admin },
      :html => {:id => 'notificationsLink'}
  }

  settings :default => {'empty' => true}, :partial => 'settings/redmine_alert_issue_settings'
end

