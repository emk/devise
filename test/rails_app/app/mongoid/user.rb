# Your code will probably be very insecure if you use Mongoid + Devise
# without this.
require 'mongoid_attr_accessible'

class User
  include Mongoid::Document

  field :username, :type => String

  devise :authenticatable, :http_authenticatable, :confirmable, :lockable, :recoverable,
         :registerable, :rememberable, :timeoutable, :token_authenticatable,
         :trackable, :validatable

  # Implemented by mongoid_attr_accessible gem.
  attr_accessible :username, :email, :password, :password_confirmation
end

