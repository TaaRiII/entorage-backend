class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.integer :user_id
      t.boolean :everyone, default: true
      t.boolean :male_only, default: false
      t.boolean :interest_based_match, default: false
      t.integer :min_age, default: 18
      t.integer :max_age, default: 30
      t.integer :group_member_count
      t.integer :max_distace, default: 50
      t.timestamps
    end
  end
end
