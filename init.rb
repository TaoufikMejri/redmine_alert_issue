require_dependency 'redmine_alert_issue/hooks'

Redmine::Plugin.register :redmine_alert_issue do
  name 'Redmine Alert Issue plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  permission :alerts, { :alerts => :index }, :public => true
  menu :application_menu, :alerts, { :controller => 'alerts', :action => 'index' }, :caption => :label_alerts, :after => :issues
  settings :default => {'empty' => true}, :partial => 'settings/redmine_alert_issue_settings'
end
