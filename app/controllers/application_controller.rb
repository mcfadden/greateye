class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :authenticate_user!
  
  private
  def has_valid_key?
    params[:key] && params[:key] == ENV['LIVE_ACCESS_KEY']
  end
end
