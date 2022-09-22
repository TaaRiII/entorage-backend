class AddInstantMatchAllowToGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :intant_match_allow, :integer, default: 1
  end
end
