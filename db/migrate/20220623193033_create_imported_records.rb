class CreateImportedRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :imported_records do |t|
      t.string :column_1
      t.string :column_2
      t.string :column_3
      t.string :column_4
      t.string :column_5
      t.string :column_6
      t.string :column_7
      t.references :imported_files, foreign_key: true
      t.references :users, foreign_key: true
      t.string :status
      t.string :message

      t.timestamps
    end
  end
end
