require 'rails_helper'
require 'spec_helper'

# TODO: Spec comments and presence / absence of buttons.

describe "Editing a project's 'status' attributes", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  before(:each) do
    @quarter       = FactoryGirl.create(:quarter, :no_deadlines_passed)
    @y             = @quarter.year
    @s             = @quarter.season
    @admin         = FactoryGirl.create(:admin)
    @advisor       = FactoryGirl.create(:advisor)
    @other_advisor = FactoryGirl.create(:advisor)
    @student       = FactoryGirl.create(:student)
    @project       = FactoryGirl.create(:project, :in_active_quarter,
                                        advisor: @advisor, status: "pending",
                                        status_published: false)
  end

  # This should be in the new_project spec file.
  context "before the admin does anything to the project" do
    context "as the admin" do
      before(:each) { ldap_sign_in(@admin) }

      context "visiting the project page" do
        it "should show a 'pending' status" do
          visit q_path(@project)
          expect(page).to have_content("Pending")
          expect(page).to have_content("Click here to edit this project's " +
                                       "information.")
        end
      end

      context "visiting the pending projects page" do
        it "should show a 'pending' status" do
          visit pending_projects_path(year: @y, season: @s)
          expect(page).to have_content("Pending")
        end
      end

    end

    context "as the advisor" do
      before(:each) { ldap_sign_in(@advisor) }

      context "visiting the project page" do
        it "should show a 'pending' status" do
          visit q_path(@project)
          expect(page).to have_content("Pending")
          expect(page).to have_content("Click here to edit this project's " +
                                       "information.")
        end
      end

    end

    # Advisors shouldn't be able to visit the pending projects page.

    context "as another advisor" do
      before(:each) { ldap_sign_in(@other_advisor) }

      context "visiting the project page" do

        it "should redirect the advisor to the homepage" do
          visit q_path(@project)
          expect(current_path).to eq(root_path)
          expect(page).to have_selector("div.alert.alert-danger")
          expect(page).to have_content("Access denied")
        end
      end
    end

    # Students shouldn't be able to visit either of the pages.

  end

  # Specifically, accepting the project.
  context "accepting or rejecting the project" do
    before(:each) { ldap_sign_in(@admin) }

    context "visiting the project page" do
      before(:each) { visit q_path(@project) }

      context "updating the project's status" do
        before(:each) do
          click_button "Accept"
        end

        it "should change the project's status" do
          expect(@project.reload.status).to eq("accepted")
          expect(@project.reload.status_published).to eq(false)
        end

        context "viewed by the admin" do

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_all_path(@advisor) }

            it "should show the updated status" do
              within("table") do
                expect(page).to have_content("Accepted (flagged, not " +
                                             "published")
                expect(page).not_to have_content("Pending")
              end
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path(year: @y, season: @s) }

            it "should not show the project" do
              expect(page).not_to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit q_path(@project) }

            it "should show the updated status" do
              within("tr", text: "Status") do
                expect(page).to have_content("Accepted (flagged, not " +
                                             "published")
                expect(page).not_to have_content("Pending")
              end
            end

            it "should still show the comments section" do
              expect(page).to have_selector("#project_comments")
              expect(page).to have_button("Request changes")
              expect(page).to have_button("Reject")
            end

          end

        end

        context "viewed by the advisor" do

          before(:each) do
            logout
            ldap_sign_in(@advisor)
          end

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_all_path(@advisor) }

            it "should show the updated status" do
              within("table") do
                expect(page).to have_content("Accepted (flagged, not " +
                                             "published")
                expect(page).not_to have_content("Pending")
              end
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path(year: @y, season: @s) }

            it "should not show the project" do
              expect(page).not_to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit q_path(@project) }

            it "should show the updated status" do
              within('tr', text: "Status") do
                expect(page).to have_content("Accepted (flagged, not " +
                                             "published)")
                expect(page).not_to have_content("Pending")
              end
            end

          end
        end

        context "viewed by the student" do

          before(:each) do
            logout
            ldap_sign_in(@student)
          end

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_all_path(@advisor) }

            it "should be redirected to the homepage" do
              expect(current_path).to eq(root_path)
              expect(page).to have_selector("div.alert.alert-danger")
              expect(page).to have_content("Access denied")
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path(year: @y, season: @s) }

            it "should not show the project" do
              expect(page).not_to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit q_path(@project) }

            it "should redirect the student to the homepage" do
              expect(current_path).to eq(root_path)
              expect(page).to have_selector("div.alert.alert-danger")
              expect(page).to have_content("Access denied")
            end
          end
        end

        context "viewed by another advisor" do

          before(:each) do
            logout
            ldap_sign_in(@other_advisor)
          end

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_all_path(@advisor) }

            it "should be redirected to the homepage" do
              expect(current_path).to eq(root_path)
              expect(page).to have_selector("div.alert.alert-danger")
              expect(page).to have_content("Access denied")
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path(year: @y, season: @s) }

            it "should not show the project" do
              expect(page).not_to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit q_path(@project) }

            it "should redirect the other advisor to the homepage" do
              expect(current_path).to eq(root_path)
              expect(page).to have_selector("div.alert.alert-danger")
              expect(page).to have_content("Access denied")
            end
          end
        end
      end
    end
  end

  context "publishing the decision (accepted)" do
    before(:each) { ldap_sign_in(@admin) }

    context "visiting the project page" do
      before(:each) { visit q_path(@project) }

      context "updating the project's status" do
        before(:each) do
          click_button "Accept"
          click_button "Publish decision"
        end

        it "should change the project's status" do
          expect(@project.reload.status).to eq("accepted")
          expect(@project.reload.status_published).to eq(true)
        end

        context "viewed by the admin" do

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_all_path(@advisor) }

            it "should show the updated status" do
              within("table") do
                expect(page).to have_content("Accepted")
                expect(page).not_to have_content("Pending")
                expect(page).not_to have_content("flagged")
              end
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path(year: @y, season: @s) }

            it "should show the project" do
              expect(page).to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit q_path(@project) }

            it "should show the updated status" do
              within("tr", text: "Status") do
                expect(page).to have_content("Accepted")
                expect(page).not_to have_content("Pending")
                expect(page).not_to have_content("flagged")
              end
            end
          end
        end

        context "viewed by the advisor" do

          before(:each) do
            logout
            ldap_sign_in(@advisor)
          end

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_all_path(@advisor) }

            it "should show the updated status" do
              within("table") do
                expect(page).to have_content("Accepted")
                expect(page).not_to have_content("Pending")
                expect(page).not_to have_content("flagged")
              end
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path(year: @y, season: @s) }

            it "should show the project" do
              expect(page).to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit q_path(@project) }

            it "should show the updated status" do
              within('tr', text: "Status") do
                expect(page).to have_content("Accepted")
                expect(page).not_to have_content("Pending")
                expect(page).not_to have_content("flagged")
              end
            end
          end
        end

        context "viewed by the student" do

          before(:each) do
            logout
            ldap_sign_in(@student)
          end

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_all_path(@advisor) }

            it "should be redirected to the homepage" do
              expect(current_path).to eq(root_path)
              expect(page).to have_selector("div.alert.alert-danger")
              expect(page).to have_content("Access denied")
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path(year: @y, season: @s) }

            it "should show the project" do
              expect(page).to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit q_path(@project) }

            it "should show the project information" do
              expect(page).to have_content(@project.name)
              expect(page).to have_content(@advisor.first_name + " " +
                                           @advisor.last_name)
            end

            it "should not show the project status" do
              within("table") do
                expect(page).not_to have_content("Status")
                expect(page).not_to have_content("Approved")
              end
            end
          end

          context "viewed by another advisor" do

            before(:each) do
              logout
              ldap_sign_in(@other_advisor)
            end

            context "visiting the advisor's my_projects page" do
              before(:each) { visit users_projects_all_path(@advisor) }

              it "should be redirected to the homepage" do
                expect(current_path).to eq(root_path)
                expect(page).to have_selector("div.alert.alert-danger")
                expect(page).to have_content("Access denied")
              end

            end

            context "visiting the projects index page" do
              before(:each) { visit projects_path(year: @y, season: @s) }

              it "should show the project" do
                expect(page).to have_content(@project.name)
              end

            end

            context "visiting the project's page" do
              before(:each) { visit q_path(@project) }

              it "should show the project information" do
                expect(page).to have_content(@project.name)
                expect(page).to have_content(@advisor.first_name + " " +
                                             @advisor.last_name)
              end

              it "should not show the project status" do
                within("table") do
                  expect(page).not_to have_content("Status")
                  expect(page).not_to have_content("Approved")
                end
              end
            end
          end
        end
      end
    end
  end

  # These outcomes should be similar to those that occur when the project is
  # unpublished.
  context "publishing the decision (rejected)" do
    before(:each) { ldap_sign_in(@admin) }

    context "visiting the project page" do
      before(:each) { visit q_path(@project) }

      context "updating the project's status" do
        before(:each) do
          click_button "Reject"
          click_button "Publish decision"
        end

        it "should change the project's status" do
          expect(@project.reload.status).to eq("rejected")
          expect(@project.reload.status_published).to eq(true)
        end

        context "viewed by the admin" do

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_all_path(@advisor) }

            it "should show the updated status" do
              within("table") do
                expect(page).to have_content("Rejected")
                expect(page).not_to have_content("Pending")
                expect(page).not_to have_content("flagged")
              end
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path(year: @y, season: @s) }

            it "should not show the project" do
              expect(page).not_to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit q_path(@project) }

            it "should show the updated status" do
              within("tr", text: "Status") do
                expect(page).to have_content("Rejected")
                expect(page).not_to have_content("Pending")
                expect(page).not_to have_content("flagged")
              end
            end
          end
        end

        context "viewed by the advisor" do

          before(:each) do
            logout
            ldap_sign_in(@advisor)
          end

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_all_path(@advisor) }

            it "should show the updated status" do
              within("table") do
                expect(page).to have_content("Rejected")
                expect(page).not_to have_content("Pending")
                expect(page).not_to have_content("flagged")
              end
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path(year: @y, season: @s) }

            it "should not show the project" do
              expect(page).not_to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit q_path(@project) }

            it "should show the updated status" do
              within('tr', text: "Status") do
                expect(page).to have_content("Rejected")
                expect(page).not_to have_content("Pending")
                expect(page).not_to have_content("flagged")
              end
            end
          end
        end

        context "viewed by the student" do
          before(:each) do
            logout
            ldap_sign_in(@student)
          end

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_all_path(@advisor) }

            it "should be redirected to the homepage" do
              expect(current_path).to eq(root_path)
              expect(page).to have_selector("div.alert.alert-danger")
              expect(page).to have_content("Access denied")
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path(year: @y, season: @s) }

            it "should not show the project" do
              expect(page).not_to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit q_path(@project) }

            it "should redirect the student to the homepage" do
              expect(current_path).to eq(root_path)
              expect(page).to have_selector("div.alert.alert-danger")
              expect(page).to have_content("Access denied")
            end
          end
        end

        context "viewed by another advisor" do

          before(:each) do
            logout
            ldap_sign_in(@other_advisor)
          end

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_all_path(@advisor) }

            it "should be redirected to the homepage" do
              expect(current_path).to eq(root_path)
              expect(page).to have_selector("div.alert.alert-danger")
              expect(page).to have_content("Access denied")
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path(year: @y, season: @s) }

            it "should not show the project" do
              expect(page).not_to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit q_path(@project) }

            it "should be redirected to the homepage" do
              expect(current_path).to eq(root_path)
              expect(page).to have_selector("div.alert.alert-danger")
              expect(page).to have_content("Access denied")
            end
          end
        end
      end
    end
  end
end
