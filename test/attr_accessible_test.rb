require 'test/test_helper'

class AttrAccessibleTest < ActiveSupport::TestCase
  test 'should allow bulk update of accessible fields' do
    user = new_user
    user.update_attributes(:email => 'updated@example.com')
    assert_equal 'updated@example.com', user.email
  end

  test 'should forbid bulk update of other fields' do
    user = new_user
    user.update_attributes(:failed_attempts => 2)
    assert_equal 0, user.failed_attempts
  end
end
