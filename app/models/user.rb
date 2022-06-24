class User < ApplicationRecord
	has_secure_password
	has_many :imported_files
	has_many :imported_records
	has_many :contacts

end
