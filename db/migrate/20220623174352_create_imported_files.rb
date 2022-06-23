class CreateImportedFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :imported_files do |t|
      t.string :filename
      t.string :status
      t.datetime :date
      t.string :format
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
