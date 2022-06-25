class AddEncryptedCreditCardToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :encrypted_credit_card, :string
  end
end
