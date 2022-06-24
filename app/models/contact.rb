class Contact < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :email, uniqueness: true


end
