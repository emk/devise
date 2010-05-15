puts "Loading User"
class User
  include Mongoid::Document

  # Like attr_accessible, but it needs to appear first.
  devise_accessible :username, :email, :password, :password_confirmation

  devise :authenticatable, :http_authenticatable, :confirmable, :lockable, :recoverable,
         :registerable, :rememberable, :timeoutable, :token_authenticatable,
         :trackable, :validatable
end

