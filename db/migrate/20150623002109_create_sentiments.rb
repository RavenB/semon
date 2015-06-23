class CreateSentiments < ActiveRecord::Migration
  def change
    create_table :sentiments do |t|
      t.string :s_name, null: false

      t.timestamps
    end
  end
end
