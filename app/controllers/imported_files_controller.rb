class ImportedFilesController < ApplicationController

	def index
		@imported_files = current_user.imported_files
	end

	def show
		@imported_file = ImportedFile.find(params[:id])
	end

	def new
		@imported_file = ImportedFile.new
	end




	def upload

		#
		# upload raw CSV data into a temporary file with asorted columns
		#
		require 'csv'
		#require "activerecord-import"

		@imported_file = ImportedFile.new
		temporal_file = params[:file]
		items = []

		@imported_file.filename = temporal_file.original_filename
		@imported_file.date = Time.now
		@imported_file.status = "Pending"
		@imported_file.user = current_user

		if @imported_file.save
			newrow=[]

			CSV.foreach(temporal_file.path) do |row|

				newrow = row[0]
				newrow << ";"+@imported_file.id.to_s
				newrow << ";"+current_user.id.to_s
				newrow << ";Pending"
				newrow << ""

				values = newrow.split(';');

				# ERB:
				# This is not a good solution. 
				# Must to be changed with "activerecord-import" gem 

				inserted_record = ImportedRecord.new
				inserted_record.column_1 = values[0]
				inserted_record.column_2 = values[1]
				inserted_record.column_3 = values[2]
				inserted_record.column_4 = values[3]
				inserted_record.column_5 = values[4]
				inserted_record.column_6 = values[5]
				inserted_record.user = current_user
				inserted_record.imported_file = @imported_file
				inserted_record.status = values[8]
				inserted_record.message = values[9]
				inserted_record.save
			  	items << values

			  	puts inserted_record.inspect

			end

			@total_rows = items.size
			flash[:notice] = "✅ Upload completed. " + @total_rows.to_s + " records in file."


		else
			@total_rows = 0
			flash[:error] = "⚠️ Warning! Something went wrong. " + @total_rows.to_s + " records in file."
		end

		#Item.import(items)
		redirect_to @imported_file

	end

	def format_headers
		@file = ImportedFile.find(params[:id])
		file_format = params[:column_1] + params[:column_2] + params[:column_3] + params[:column_4] + params[:column_5] + params[:column_6]

		# avoid duplicated headers in file
		if file_format.squeeze() == file_format
			@file.format = file_format
			@file.status = "On Hold"
			@file.save 

			# transform from raw data to contacts
			import(@file)
			redirect_to imported_files_path
		else
			flash[:error] = "⚠️ Error. Columns cannot be duplicated."
			redirect_to imported_file_path

		end
	end


	private

	def import(file)

		puts "========================================================================================"
		puts "Start validation for " + file.id.to_s
		sleep 1

		row_format = file.format
		file.imported_records.each do |row|
			insert_record(row,row_format)

		end

		sleep 1

		puts "End of validation for " + file.id.to_s
		puts "========================================================================================"

	end

	def insert_record(row,row_format)
		

		@contact = Contact.new
		@contact.user = current_user
		
		# extract correct values from columns with numbers
		for i in 0..5 do 
			case row_format[i]
			when "N"
				@contact.name = row.send("column_" + (i+1).to_s)
			when "B"
				begin
					@contact.birth = Date.parse(row.send("column_" + (i+1).to_s))
   				 rescue ArgumentError
   				 	@contact.birth = nil
    			end

			when "P"
				@contact.phone = row.send("column_" + (i+1).to_s)
			when "A"
				@contact.address = row.send("column_" + (i+1).to_s)
			when "C"
				@contact.credit_card = row.send("column_" + (i+1).to_s)
			when "E"
				@contact.email = row.send("column_" + (i+1).to_s)
			end
		end

		@contact.save

	end




end
