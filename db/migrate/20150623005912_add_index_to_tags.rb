class AddIndexToTags < ActiveRecord::Migration
  def change
    add_index :tags, :ancestry
    add_index :tags, :campaign_id
  end
end
