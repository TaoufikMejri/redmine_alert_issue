class Alert < ActiveRecord::Base
  belongs_to :issue

  scope :visible, -> { User.current.admin ? where(nil) : nil }
  delegate :project, :tracker, :status, :updated_on, :due_date, :start_date, :estimated_hours, :created_on, :closed_on,
           :category, :subject, :assigned_to, :author, :priority, :done_ratio, to: :issue

end
