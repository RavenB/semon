class AddLastAccessedToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :last_accessed, :datetime
  end
end
