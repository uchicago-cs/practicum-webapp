require 'rails_helper'
require 'spec_helper'

RSpec.describe User, :type => :model do

  before do
    let(@student) { FactoryGirl.create(:student) }
    let(@advisor) { FactoryGirl.create(:advisor) }
    let(@project) { FactoryGirl.create(:project) }
    let(@project) { FactoryGirl.create(:submission) }
  end

end
