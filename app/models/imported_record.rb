class ImportedRecord < ApplicationRecord
  belongs_to :imported_files
  belongs_to :users
end
