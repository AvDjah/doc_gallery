class CreateDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :documents do |t|
      t.string :title
      t.string :document_name
      t.string :description
      t.string :document_file_name
      t.string :extension
      t.integer :document_size
      t.string :document_type
      t.string :keywords
      t.string :document_guid
      t.references :parent_category, foreign_key: { to_table: :categories }, null: false


      t.timestamps
    end
  end
end
