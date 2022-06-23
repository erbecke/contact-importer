class ImportedFilesController < ApplicationController

	def new
		@imported_file = ImportedFile.new
	end

	def show
		@imported_file = ImportedFile.find(params[:id])

	end

	def import
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
				# This is not a performanced solution. Need to be changed with "activerecord-import" gem 

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
			flash[:notice] = "Upload completed. " + @total_rows.to_s + " records in file."


		else
			@total_rows = 0
			flash[:error] = "Warning! Something went wrong. " + @total_rows.to_s + " records in file."
		end




		# Importing without model validations

		#Item.import(items)
		redirect_to @imported_file

	end


end
