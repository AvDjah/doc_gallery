class AddLevelToCategory < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :level, :integer, default: 1
  end
end
