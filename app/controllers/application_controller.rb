class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authorize

  protected

  def authorize
    if session[:user_id] == nil or User.find_by(id: session[:user_id]) == nil
      redirect_to login_path, notice: "Please login"
    else
      @logged_in = User.find_by id: session[:user_id]
    end
  end
end
