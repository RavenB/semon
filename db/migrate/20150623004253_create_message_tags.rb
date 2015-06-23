class CreateMessageTags < ActiveRecord::Migration
  def change
    create_table :message_tags do |t|
      t.integer :message_id, null: false
      t.integer :tag_id, null: false

      t.timestamps
    end
  end
end
