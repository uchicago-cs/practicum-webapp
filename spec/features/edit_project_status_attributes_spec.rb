require 'rails_helper'
require 'spec_helper'

describe "Editing a submission's 'status' attributes", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  before(:each) do
    @quarter    = FactoryGirl.create(:quarter, :no_deadlines_passed)
    @admin      = FactoryGirl.create(:admin)
    @advisor    = FactoryGirl.create(:advisor)
    @student    = FactoryGirl.create(:student)
    @project    = FactoryGirl.create(:project, :in_current_quarter,
                                     advisor: @advisor, status: "pending",
                                     status_published: false)
  end

  context "before the admin does anything to the project" do
    context "as the admin" do
      before(:each) { ldap_sign_in(@admin) }

      context "visiting the project page" do
        it "should show a 'pending' status" do
          visit project_path(@project)
          expect(page).to have_content("Pending")
          expect(page).to have_content("Click here to edit this project's " +
                                       "information.")
        end
      end

      context "visiting the pending projects page" do
        it "should show a 'pending' status" do
          visit pending_projects_path
          expect(page).to have_content("Pending")
        end
      end

    end

    context "as the advisor" do
      before(:each) { ldap_sign_in(@advisor) }

      context "visiting the project page" do
        it "should show a 'pending' status" do
          visit project_path(@project)
          expect(page).to have_content("Pending")
          expect(page).to have_content("Click here to edit this project's " +
                                       "information.")
        end
      end

    end

    # Advisors shouldn't be able to visit the pending projects page.
    # Students shouldn't be able to visit either of the pages.

  end

  # Specifically, accepting the project.
  context "accepting or rejecting the project" do
    before(:each) { ldap_sign_in(@admin) }

    context "visiting the project page" do
      before(:each) { visit project_path(@project) }

      context "updating the project's status" do
        before(:each) do
          choose "Approve"
          click_button "Update project status"
        end

        it "should change the project's status" do
          expect(@project.reload.status).to eq("accepted")
          expect(@project.reload.status_published).to eq(false)
        end

        context "viewed by the admin" do

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_path(@advisor) }

            it "should show the updated status" do
              within("table") do
                expect(page).to have_content("Accepted (flagged, not " +
                                             "published")
                expect(page).not_to have_content("Pending")
              end
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path }

            it "should not show the project" do
              expect(page).not_to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit project_path(@project) }

            it "should show the updated status" do
              within('tr', text: "Status") do
                expect(page.find("#project_status_accepted")).to be_checked
                expect(page.find("#project_status_published")).
                  not_to be_checked
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
            before(:each) { visit users_projects_path(@advisor) }

            it "should show the updated status" do
              within("table") do
                expect(page).to have_content("Accepted (flagged, not " +
                                             "published")
                expect(page).not_to have_content("Pending")
              end
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path }

            it "should not show the project" do
              expect(page).not_to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit project_path(@project) }

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
            before(:each) { visit users_projects_path(@advisor) }

            it "should be redirected to the homepage" do
              expect(current_path).to eq(root_path)
              expect(page).to have_selector("div.alert.alert-danger")
              expect(page).to have_content("Access denied")
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path }

            it "should not show the project" do
              expect(page).not_to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit project_path(@project) }

            it "should redirect the student to the homepage" do
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
      before(:each) { visit project_path(@project) }

      context "updating the project's status" do
        before(:each) do
          choose "Approve"
          check "Publish status"
          click_button "Update project status"
        end

        it "should change the project's status" do
          expect(@project.reload.status).to eq("accepted")
          expect(@project.reload.status_published).to eq(true)
        end

        context "viewed by the admin" do

          context "visiting the advisor's my_projects page" do
            before(:each) { visit users_projects_path(@advisor) }

            it "should show the updated status" do
              within("table") do
                expect(page).to have_content("Accepted")
                expect(page).not_to have_content("Pending")
                expect(page).not_to have_content("flagged")
              end
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path }

            it "should show the project" do
              expect(page).to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit project_path(@project) }

            it "should show the updated status" do
              within('tr', text: "Status") do
                expect(page.find("#project_status_accepted")).to be_checked
                expect(page.find("#project_status_published")).to be_checked
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
            before(:each) { visit users_projects_path(@advisor) }

            it "should show the updated status" do
              within("table") do
                expect(page).to have_content("Accepted")
                expect(page).not_to have_content("Pending")
                expect(page).not_to have_content("flagged")
              end
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path }

            it "should show the project" do
              expect(page).to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit project_path(@project) }

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
            before(:each) { visit users_projects_path(@advisor) }

            it "should be redirected to the homepage" do
              expect(current_path).to eq(root_path)
              expect(page).to have_selector("div.alert.alert-danger")
              expect(page).to have_content("Access denied")
            end

          end

          context "visiting the projects index page" do
            before(:each) { visit projects_path }

            it "should show the project" do
              expect(page).to have_content(@project.name)
            end

          end

          context "visiting the project's page" do
            before(:each) { visit project_path(@project) }

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

  context "publishing the decision (rejected)" do
    before(:each) { ldap_sign_in(@admin) }

    context "visiting the project page" do
      before(:each) { visit project_path(@project) }

      context "updating the project's status" do
        before(:each) do
          choose "Reject"
          check "Publish status"
          click_button "Update project status"
        end

        it "should change the project's status" do
          expect(@project.reload.status).to eq("rejected")
          expect(@project.reload.status_published).to eq(true)
        end

        context "viewed by the admin" do
          # Visiting the advisor's my_projects page
          # Visiting the projects index page
          # Visiting the project's page
        end

        context "viewed by the advisor" do
          # Visiting the my_projects page
          # Visiting the projects index page
          # Visiting the project's page
        end

        context "viewed by the student" do
          # Visiting the advisor's my_projects page
          # Visiting the projects index page
          # Visiting the project's page
        end

      end

    end

  end

  context "editing the proposal" do



  end

end
