class ChageSettingDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :settings, :everyone, false
  end
end
