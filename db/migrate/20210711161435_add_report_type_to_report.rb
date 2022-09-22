class AddReportTypeToReport < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :report_type, :integer, default: 0
  end
end
