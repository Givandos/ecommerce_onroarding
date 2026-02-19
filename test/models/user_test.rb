require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should belong to company" do
    assert_respond_to User.new, :company
  end
end
