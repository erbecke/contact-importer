class ImportedFile < ApplicationRecord
  belongs_to :user
  has_many :imported_records
end
