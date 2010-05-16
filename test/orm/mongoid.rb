require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('devise-test-suite-mongoid')
  config.allow_dynamic_fields = false
end

require File.join(File.dirname(__FILE__), '..', 'rails_app', 'config', 'environment')
require 'test_help'

module Mongoid::Document
  # TODO This should not be required.
  def invalid?
    !valid?
  end
end

# Fix our validations to return the same strings as ActiveRecord.
module Validatable
  class ValidatesUniquenessOf < ValidationBase #:nodoc:
    def message(instance)
      "has already been taken"
    end    
  end

  class ValidatesLengthOf < ValidationBase #:nodoc:
    def message(instance)
      mins  = [minimum, is, within.nil? ? nil : within.first].compact
      maxes = [maximum, is, within.nil? ? nil : within.last].compact
      value = instance.send(self.attribute)

      if maxes.length > 0 && !value.nil? && value.length > maxes.first
        "is too long (maximum is #{maxes.first} characters)"
      elsif mins.length > 0 && !value.nil? && value.length < mins.first
        "is too short (minimum is #{mins.first} characters)"
      else
        "is invalid"
      end
    end
  end
end

# Clear our test collections between test cases.
class ActiveSupport::TestCase
  setup do
    User.delete_all
    Admin.delete_all
  end
end
