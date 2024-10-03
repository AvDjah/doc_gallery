class AddSortOrderToCategory < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :sort_order, :integer, default: 0
  end
end
