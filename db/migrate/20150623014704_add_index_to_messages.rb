class AddIndexToMessages < ActiveRecord::Migration
  def change
    add_index :messages, :campaign_id
    add_index :messages, :category_id
    add_index :messages, :sentiment_id
  end
end
