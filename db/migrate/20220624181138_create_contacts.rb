class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.string :name
      t.date :birth
      t.string :phone
      t.string :address
      t.string :credit_card
      t.string :franchise
      t.string :email
      t.string :encrypted_credit_card
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
