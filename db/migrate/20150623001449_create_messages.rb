class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :m_author, null: false
      t.text :m_text, null: false
      t.datetime :m_moment, null: false
      t.string :m_origin, null: false
      t.text :m_details
      t.integer :m_rating
      t.integer :campaign_id, null: false
      t.integer :category_id
      t.integer :sentiment_id

      t.timestamps
    end
  end
end
