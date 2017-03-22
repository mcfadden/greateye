class User < ActiveRecord::Base
  devise :database_authenticatable, :rememberable

  def admin!
    update(admin: true)
  end

end
