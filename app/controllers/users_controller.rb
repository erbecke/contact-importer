class UsersController < ApplicationController

	def new
   		@user = User.new
	end

	def create
   		@user = User.new(user_params)
   		if @user.save
     		flash[:notice] = "User created."
     		redirect_to root_path
   		else
     		render 'new'
   		end
 	end

 	def show
 			# pending: validate authorization

 		    @user = User.find(params[:id])
 		    # @session = session[:id]

 	end

 	def logout
 		redirect_to '/logout'
 	end

private

 	def user_params
   		params.require(:user).permit(:username, :email, :password)
	end


end
