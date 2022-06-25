# Contact Importer

This project was made as a technical challenge.

Environment:

Ruby version: 2.7.6
Rails version: 5.2.8
Database: Sqlite3

System dependencies:
Rails 5.2.8 standard with a few added gems for Boostrap and pagination (kaminari).

Datasets with user stories and cases located in /cases folder

How to use:
1. Run a localhost/Puma server and access to root. 
2. Create a new user and after that log in using your email/password.
3. Upload your desired CSV file, define the header format and process it.
4. Check in Contacts page all the imported contacts.
5. Upload other files to add new contacts.

Some considerations:
* The system uploads the CSV file in a temporary structure before runs the validations.

* For security reasons the system analyzes each column during the upload and automatically detects the credit cards to mask them and to encrypt the original number in a non-reversible format using the bcript gem. Only encrypted card numbers are stored in the database during all the processes. 

* The process could be done differently with a better context information, for example: the average size of CSV file, number of concurrent users, etc.

* Quality vs quantity: I chose to do a working system with all the features, so I did not have any time to optimize o rewrite the code in a better way.

* The short time forced me to create a working code, but some functions could be have a much better coding. 
 
* I have run the validations, however the system has not had a formal testing and QA process.
* The user management system and signup process were build only with minimal features, and without a proper security consideration. 


Known bugs:
A minor strange behaviour with Chrome Versión 102.0.5005.115 (Build oficial) (x86_64 in Mac OS: if you upload the file, but instead of validating it you go back to main menu (without validation), when you try to validate it the Validation button only works after page refresh with the browser.



