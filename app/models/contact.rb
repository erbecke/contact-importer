class Contact < ApplicationRecord
  
  belongs_to :user

  validates :email, uniqueness: true, presence: { message:  " cannot be blank." }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: " must be a valid address." } 

  validates :name, presence: { message:  " cannot be blank." },
                         format: { with: /[^a-zA-Z:,-]/i, message:" must only contain letters." },
                         length: { minimum: 2, message:  " must be at least 2 letters." }
 
  validates :birth, presence: { message:  " date cannot be blank." }
  
  VALID_PHONE_REGEX = /\A\(\+\d\d\) \d\d\d \d\d\d \d\d \d\d\z/

  validates :phone, presence: { message:  " cannot be blank." },
                   format: { with: VALID_PHONE_REGEX, message:" must be a valid international phone number like (+00) 000-000-00-00 " }
  
  validates :address, presence: { message:  " cannot be blank." }
  validates :franchise, presence: { message:  " cannot be found." }
 
  

end
