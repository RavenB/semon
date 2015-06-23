class AddIndexToCampaigns < ActiveRecord::Migration
  def change
    add_index :campaigns, :c_name, unique: true
  end
end
