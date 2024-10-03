class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :description
      t.string :created_by
      t.string :remarks
      t.references :parent_category, foreign_key: { to_table: :categories }
      t.timestamps
    end
  end
end
