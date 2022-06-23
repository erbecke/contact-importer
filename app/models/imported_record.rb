class ImportedRecord < ApplicationRecord
  belongs_to :imported_file
  belongs_to :user
end
