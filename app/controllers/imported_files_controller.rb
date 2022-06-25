class ImportedFilesController < ApplicationController

	def index
		@imported_files = current_user.imported_files
	end

	def show
		@imported_file = ImportedFile.find(params[:id])

		if (@imported_file.status == nil or @imported_file.status == "Pending" or @imported_file.status == "") then 
			@edit_table_header = true
			@row_limit = 3
			@display_imported_record_details = false
			@row_display_errors_only = false
			@filtered_imported_records = @imported_file.imported_records.limit(@row_limit)

		else
			@edit_table_header = false
			@row_limit = @imported_file.imported_records.size 
			@display_imported_record_details = true
			@row_display_errors_only = true
			@filtered_imported_records = @imported_file.imported_records.where("status = ?", "Error").limit(@row_limit)
			# @filtered_imported_records = 

		end
	end

	def new
		@imported_file = ImportedFile.new
	end


	def upload

		#
		# upload raw CSV data into a temporary file with asorted columns
		#
		# Comment by ERB:
		# performance could be improved for large datasets using gems 
		# not running on background

		require 'csv'
		
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
				unless newrow == nil 

					newrow << ";"+@imported_file.id.to_s
					newrow << ";"+current_user.id.to_s
					newrow << ";Pending"
					newrow << ""

					values = newrow.split(';');

					# ERB:
					# This is not the best solution. 
					# Must to be changed with "activerecord-import" gem or similar to reduce database load
					# require "activerecord-import" 
					# 

					# for security reasons we seek and hide credit cards in any column
					inserted_record = ImportedRecord.new
					inserted_record.column_1 = protect_credit_card(values[0]) 
					inserted_record.column_2 = protect_credit_card(values[1])
					inserted_record.column_3 = protect_credit_card(values[2])
					inserted_record.column_4 = protect_credit_card(values[3])
					inserted_record.column_5 = protect_credit_card(values[4])
					inserted_record.column_6 = protect_credit_card(values[5])
					inserted_record.column_7 = @franchise
					inserted_record.column_8 = @encrypted_credit_card


					inserted_record.user = current_user
					inserted_record.imported_file = @imported_file
					inserted_record.status = values[8]
					inserted_record.message = values[9]
					inserted_record.save
				  	items << values

			  	end
			end

			@total_rows = items.size
			flash[:notice] = "✅ Upload completed. " + @total_rows.to_s + " records in file."


		else
			@total_rows = 0
			flash[:error] = "⚠️ Warning! Something went wrong. " + @total_rows.to_s + " records in file."
		end

		redirect_to @imported_file

	end


	def format_headers
		# 
		# define columns order
		#

		@file = ImportedFile.find(params[:id])
		file_format = params[:column_1] + params[:column_2] + params[:column_3] + params[:column_4] + params[:column_5] + params[:column_6]

		# avoid duplicated headers in file
		if file_format.squeeze() == file_format
			@file.format = file_format
			@file.status = "On Hold"
			@file.save 

			# transform from raw data to contacts
			import(@file)
			redirect_to imported_file_path
		else
			flash[:error] = "⚠️ Error. Columns cannot be duplicated."
			redirect_to imported_file_path

		end
	end


	private


	def is_number? string
  		true if Float(string) rescue false
	end

	def import(file)

		file.status = "Processing"
		row_format = file.format
		@row_index = 0

		file.imported_records.each do |row|
			insert_record(row,row_format)

		end

		#
		# Import Process Summary:
		# 
		msg_row_count = file.imported_records.size.to_s + " rows processed. "
		rows_with_errors = file.imported_records.where("status = ?", "Error").count

		if @summary_errors = rows_with_errors > 0
			
			msg = "⚠️ Process failed. "
			msg << msg_row_count 
			msg << rows_with_errors.to_s + " rows couldn't be imported. "
			file.status = "Failed"
			file.save
			flash[:error] = msg

		else
			file.status = "Finished"
			file.save 
			msg = "✅ Process successfully finished. " 
			msg << msg_row_count

			flash[:notice] = msg

		end

	end

	def insert_record(row,row_format)
		@row_index += 1
		msgs = "Row #" + @row_index.to_s 

		@contact = Contact.new
		@contact.user = current_user
		@contact.franchise = row.send("column_7")
		@contact.encrypted_credit_card = row.send("column_8")
		
		# extract correct values from columns with numbers
		for i in 0..5 do 
			case row_format[i]
			when "N"
				@contact.name = row.send("column_" + (i+1).to_s)
			when "B"
				begin
					raw_date = row.send("column_" + (i+1).to_s)
					@contact.birth = Date.parse(raw_date)

					# ACCEPTS ONLY ISO 8601 dates (%Y%m%d ) and (%F)
	    			unless (@contact.birth.strftime("%Y-%m-%d") == raw_date or @contact.birth.strftime("%F") == raw_date ) then
						msgs = msgs + " | Birth date must have ISO 8601 format" 
					end

   				 rescue ArgumentError
   				 	@contact.birth = nil
    			end

			when "P"
				@contact.phone = row.send("column_" + (i+1).to_s)
				@contact.phone.gsub("-", " ")				
			when "A"
				@contact.address = row.send("column_" + (i+1).to_s)
			when "C"
				@contact.credit_card = row.send("column_" + (i+1).to_s)
			when "E"
				@contact.email = row.send("column_" + (i+1).to_s)
			end
		end

		@contact.save

	  	if @contact.errors.any?
	        @contact.errors.full_messages.each do |msg|
	          msgs = msgs + " | " + msg 
	        end
	        row.message = msgs
	        row.status = "Error"
	        row.save
	    else 
	    	row.message = ""
	        row.status = "Imported Ok"
	        row.save
	    end
	end


	def protect_credit_card(data)
		# By ERB:
		#
		# for security reason the system detects if this column is a credit card number
		# if the column is a credit card it will be masked and encrypt the original number in other column
		# encrypton method is not reversible (bcrypt)

		return if data == nil

		if (data.length >= 14 and data.length <= 16) and (is_number?(data)) then
			# if credit card found
			if detect_franchise(data) != nil then
				masked_credit_card = "xxxx-xxxx-xxxx-"+data.last(4).to_s
				# encrypt original credit card number
				encrypt_credit_card(data)
				return masked_credit_card
			else
				# not a credit card with franchise
				return data
			end 
		else
			# not a credit card
			return data
		end
	end

	def detect_franchise(credit_card)
		require 'matrix'
	    iin_source = credit_card
	    
	    if iin_source then 
	      i=0
	      # 
	      # IIN Codes 
	      # Source: https://en.wikipedia.org/wiki/Payment_card_number#Major_Industry_Identifier_.28MII.29
	      # Data structure: string lenght, IINN code range start, IIN code range end, franchise

	      iin_data = [
	      	[1,1,1,"UATP"],
	        [1,1,1,"GPN"],
	        [1,2,2,"GPN"],
	        [1,6,6,"GPN"],
	        [1,1,7,"GPN"],
	        [1,8,8,"GPN"],
	        [1,9,9,"GPN"],
	       	[1,4,4,"Visa"],
	        [2,34,34, 'American Express'],
	        [2,37,37,'American Express'], 
	        [2,31,31,"China T-Union"],
	        [2,62,62,"China UnionPay"],
	        [4,6011,6011,"Discovery"],
	        [3,644,649, "Discovery"],
	        [6,622126,622925, "Discovery/China UnionPay"],
	        [2,36,36,"Diners Club International"],
	        [2,54,54,"Diners Club US & Canada"],
	        [8,60400100,60420099,"UkrCard"],
	        [2,60,60,"RuPay"],
	        [2,65,65,"RuPay"],
	        [2,81,81,"RuPay"],
	        [2,82,82,"RuPay"],
	        [3,508,508,"RuPay"],
	        [3,353,353,"RuPay/JCB"],
	        [3,356,356,"RuPay/JCB"],
	        [3,636,636,"InterPayment"],
	        [3,637,639,"InstaPayment"],
	        [4,3528,3589,"JCB"],
	        [4,6759,6759,"Maestro UK"],
	        [6,676770,676770,"Maestro UK"],
	        [6,676774,676774,"Maestro UK"],
	        [4,5018,5018,"Maestro"],
	        [4,5020,5020,"Maestro"],
	        [4,5038,5038,"Maestro"],
	        [4,5893,5893,"Maestro"],
	        [4,6304,6304,"Maestro"],
	        [4,6759,6759,"Maestro"],
	        [4,6761,6761,"Maestro"],
	        [4,6762,6762,"Maestro"],
	        [4,6763,6763,"Maestro"],
	        [4,5019,5019,"Dankort"],
	        [4,4071,4071,"Dankort"],
	        [4,2200,2204,"Mir"],
	        [4,2205,2205,"Borika"],
	        [7,6054740,6054744,"NPS Pridnestrovie"],
	        [4,2221,2720,"Mastercard"],
	        [2,51,55,"Mastercard"],
	        [2,65,65,"Troy"],
	        [4,4026,4026,"Visa Electron"],
	        [6,417500,417500,"Visa Electron"],
	        [4,4508,4508,"Visa Electron"],
	        [4,4844,4844,"Visa Electron"],
	        [4,4913,4913,"Visa Electron"],
	        [4,4917,4917,"Visa Electron"],
	        [6,506099,506198,"Verve"],
	        [6,650002,650027,"Verve"],
	        [6,507865,507964,"Verve"],
	        [6,357111,357111,"LankaPay"],
	        [4,8600,8600,"UzCard"],
	        [4,9860,9860,"Humo"]
	      ]

	      mat = Matrix[ *iin_data ]
	      mat.column(0).to_a.each  do |iic_range|

	      # validates if cc_iic_code is in a known range of iin_data
	      iic_data_code_start = mat[i,1]
	      iic_data_code_end = mat[i,2]
	      iic_data_franchise = mat[i,3]

	      # extract the iic code from contact 
	      cc_iic_code = credit_card[0..iic_range-1]
	   
	      if (cc_iic_code.to_i >= iic_data_code_start.to_i and cc_iic_code.to_i <= iic_data_code_end.to_i) then 
	        @franchise = iic_data_franchise
	        return @franchise
	      end
	      i += 1
	      end
	    end  
	end

	def encrypt_credit_card(data)

		# using bcrypt gem to create a non-reversible encryption in credit card numbers
		require 'bcrypt'

		# for performance reasons cost has changed 6. 
		BCrypt::Engine.cost = 6
		@encrypted_credit_card = BCrypt::Password.create(data)

		return @encrypted_credit_card
	end

end
