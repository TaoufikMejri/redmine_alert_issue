class CreateAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts do |t|
      t.integer :issue_id
      t.datetime :begin_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
