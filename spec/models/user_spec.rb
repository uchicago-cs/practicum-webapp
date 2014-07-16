require 'rails_helper'
require 'spec_helper'

RSpec.describe User, :type => :model do

  before do
    let(@student) { FactoryGirl.create(:student) }
    let(@advisor) { FactoryGirl.create(:advisor) }
    let(@project) { FactoryGirl.create(:project) }
  end

  describe "when user submits an application" do
    @student.submissions.build
  end

end
