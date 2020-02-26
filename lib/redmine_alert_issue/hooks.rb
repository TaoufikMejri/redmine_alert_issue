module RedmineAlertIssue
  module Hooks
    class ControllerIssuesNewAfterSave < Redmine::Hook::ViewListener
      def controller_issues_new_after_save(context={})
        issue_id = context[:issue].id
        issue = Issue.find issue_id
        issue_status = issue.status.name
        setting_status = Setting.plugin_redmine_alert_issue['issue_status']

        current_time = DateTime.now
        current_day = current_time.day
        current_month = current_time.month
        current_year = current_time.year
        current_wday = current_time.wday
        current_zone = current_time.zone

        finish_work_time = DateTime.new(current_year, current_month, current_day, 18, 0, 0)
        finish_work_time = finish_work_time.change(offset: current_zone)

        if issue_status == setting_status
          add_hours = 2
          next_time = current_time + 2.hours
          if (next_time > finish_work_time) && ((1...5).include? current_wday)
            add_hours = add_hours + 14
          elsif (next_time > finish_work_time) && (current_wday == 5)
            add_hours = add_hours + 14 + 48
          end
          AlertWorker.perform_in(current_time + add_hours.hours, issue_id, setting_status)
        end
      end

      def controller_issues_edit_after_save(context={})
        issue_id = context[:issue].id
        issue = Issue.find issue_id
        issue_status = issue.status.name
        setting_status = Setting.plugin_redmine_alert_issue['issue_status']
        alert = Alert.find_by(issue_id: issue_id)

        if alert && (issue_status != setting_status)
          alert.update_attributes(end_time: DateTime.now)
        end
      end
    end

    class NotificationsHookListener < Redmine::Hook::ViewListener
      render_on :view_layouts_base_html_head, :partial => "alerts/layouts_base_html_head"
    end
  end
end