class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
  end

  def create
    username = params[:username].strip
    user = User.find_by(username: username)
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to user_index_path, notice: "Successfully logged in #{user.username}"
    else
      redirect_to login_url, notice: "Invalid/user password combination."
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged Out"
  end
end
