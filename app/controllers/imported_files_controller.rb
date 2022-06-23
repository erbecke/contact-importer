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

			CSV.foreach(temporal_file.path, headers: true) do |row|
			  items << row.to_h

			  puts row.inspect
			end

			@total_rows = items.size

			flash[:notice] = "Upload completed. " + @total_rows.to_s + " records in file."


		else
			@total_rows = 0
		end

		#Item.import(items)
		redirect_to @imported_file

	end


end
