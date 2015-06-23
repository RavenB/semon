class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :cat_name, null: false
      t.string :cat_description

      t.timestamps
    end
  end
end
