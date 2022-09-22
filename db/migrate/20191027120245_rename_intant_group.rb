class RenameIntantGroup < ActiveRecord::Migration[5.2]
  def change
    rename_column :groups, :intant_match_allow, :instant_match_allow
  end
end
