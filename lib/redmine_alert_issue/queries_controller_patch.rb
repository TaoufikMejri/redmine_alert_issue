require_dependency 'queries_controller'

module RedmineAlertIssue
  module QueriesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def redirect_to_alert_query(options)
        redirect_to alerts_path
      end
    end
  end
end

QueriesController.send(:include, RedmineAlertIssue::QueriesControllerPatch)
