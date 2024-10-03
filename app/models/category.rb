class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: "parent_category_id"
  has_many :documents, class_name: "Document", foreign_key: "parent_category_id"
  validates :name, :sort_order, presence: true

  before_save :check_sort_order

  def check_sort_order
    if self.sort_order == 0
      self.sort_order = 1e5
    end
  end
end
