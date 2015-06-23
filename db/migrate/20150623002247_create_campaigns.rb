class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :c_name, null: false
      t.string :c_description
      t.datetime :c_start, null: false
      t.datetime :c_end, null: false
      t.integer :c_status, null: false, default: 0

      t.timestamps
    end
  end
end
