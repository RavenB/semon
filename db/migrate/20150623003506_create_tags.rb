class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :t_name, null: false
      t.string :ancestry
      t.integer :t_count, null: false, default: 0
      t.string :t_connection
      t.integer :campaign_id, null: false

      t.timestamps
    end
  end
end
