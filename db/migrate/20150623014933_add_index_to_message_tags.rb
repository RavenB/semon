class AddIndexToMessageTags < ActiveRecord::Migration
  def change
    add_index :message_tags, :message_id
    add_index :message_tags, :tag_id
  end
end
