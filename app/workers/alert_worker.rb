class AlertWorker
  include Sidekiq::Worker

  def perform(issue_id, setting_status)
    issue = Issue.find issue_id
    issue_status = issue.status.name
    if issue_status == setting_status
      Alert.create(issue_id: issue_id, begin_time: DateTime.now)
    end
  end
end
