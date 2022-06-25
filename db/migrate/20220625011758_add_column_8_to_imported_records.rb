class AddColumn8ToImportedRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :imported_records, :column_8, :string
  end
end
