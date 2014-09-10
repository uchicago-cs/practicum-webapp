require 'rails_helper'
require 'spec_helper'

describe "Users viewing pages", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  # Again, we want to reduce redundancy. Make this DRY!
  context "viewing user profiles" do
    before(:each) do
      @user_1 = FactoryGirl.create(:user)
    end
  end

end
