puts "Loading Admin"
class Admin
  include Mongoid::Document

  devise :authenticatable, :registerable, :timeoutable

  def self.find_for_authentication(conditions)
    last(:conditions => conditions)
  end
end
