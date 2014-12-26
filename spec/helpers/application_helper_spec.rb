require "spec_helper"
include ActionView::Helpers::UrlHelper

# Controller spec..?
describe ApplicationHelper, type: :controller do
  before do
    @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
    @year    = @quarter.year
    @season  = @quarter.season
    @advisor = FactoryGirl.create(:advisor)
    @project = FactoryGirl.create(:project, quarter: @quarter,
                                  advisor: @advisor, status: "accepted",
                                  status_published: true)
  end

  describe "#q_link_to" do
    it "returns the expected quarter-specific link" do
      expect(q_link_to("here", @project)).
        to eq(link_to("here", project_path(@project, year: @year,
                                           season: @season)))
    end
  end

  describe "#q_path" do
    it "returns the expected quarter-specific path" do
      expect(q_path(@project)).to eq(project_path(@project, year: @year,
                                                  season: @season))
    end
  end

  describe "#q_url" do
    it "returns the expected quarter-specific url" do
      expect(q_url(@project)).to eq(project_url(@project, year: @year,
                                                season: @season))
    end
  end
end
