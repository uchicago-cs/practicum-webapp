Practicum::Application.routes.draw do

  # Remember: the placement of routes within this file matters!

  root 'pages#home'

  match "/applications/update_all_submissions",
        to: "pages#update_all_submissions", via: "patch",
        as: "update_all_submissions"
  match "/applications/approve_all_statuses", to: "pages#change_all_statuses",
        via: "patch", as: "approve_all_statuses", change: "approve"
  match "/applications/publish_all_statuses", to: "pages#change_all_statuses",
        via: "patch", as: "publish_all_statuses", change: "publish"
  match "/applications/drafts", to: "pages#submission_drafts", via: "get",
        as: "submission_drafts"
  match "/projects/pending/publish_all", to: "projects#publish_all_pending",
        via: "patch", as: "publish_all_pending_projects"
  match "/evaluations", to: "evaluations#index", via: "get", as: "evaluations"

  resources :evaluation_templates, except: :edit do
    member do
      post  "add_question"
      patch "update_question"
    end
  end

  resources :projects, shallow: true do
    resources :submissions, path: 'applications', shallow: true do
      resources :evaluations, only: [:new, :create, :show]

      member do
        patch "accept_or_reject"
        patch "update_status"
      end

    end

    collection do
      get "pending"
      resources :quarters
    end

    member do
      patch "update_status"
    end

  end

  match "/applications/:id/resume",
  to: "submissions#download_resume", via: "get", as: "download_resume"

  devise_for :users, skip: [:sessions, :registrations]
  devise_scope :user do
    get "/signin" => "sessions/sessions#new", as: :new_user_session
    post "/signin" => "sessions/sessions#create", as: :user_session
    delete "/signout" => "sessions/sessions#destroy", as: :destroy_user_session

    # Prevent users from deleting their own accounts.
    resource :registration,
    only: [:new, :create, :edit, :update],
    controller: "devise/registrations",
    as: :user_registration do
      get :cancel
    end
  end

  match "/users", to: "users#index", via: "get"
  match "/users/:id", to: "users#show", via: "get", as: "user"
  match "/users/:id", to: "users#update", via: "patch"
  match "/users/:id/my_projects", to: "users#my_projects", via: "get",
        as: "users_projects"
  match "/users/:id/my_applications", to: "users#my_submissions", via: "get",
        as: "users_submissions"
  match "/applications", to: "pages#submissions", via: "get", as: "submissions"
  match "/projects/:id", to: "projects#clone_project", via: "post"
  match "/request_advisor_access", to: "pages#request_advisor_access",
        via: "get"
  match "/request_advisor_access", to: "pages#send_request_for_advisor_access",
        via: "post"
end
