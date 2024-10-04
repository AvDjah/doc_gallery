class User < ApplicationRecord
  has_secure_password :password
  validates :username, presence: true, uniqueness: true
end
