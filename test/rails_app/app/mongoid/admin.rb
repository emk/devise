puts "Loading Admin"
class Admin
  include Mongoid::Document

  field :username, :type => String

  devise :authenticatable, :registerable, :timeoutable

  def self.find_for_authentication(conditions)
    last(:conditions => conditions)
  end
end
