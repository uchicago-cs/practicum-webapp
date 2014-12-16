Practicum::Application.routes.draw do

  # Remember: the placement of routes within this file matters!

  root 'pages#home'

  resources :quarters

  resources :evaluation_templates, except: :edit do
    member do
      post  "add_question"
      patch "update_question"
      patch "update_survey"
      patch "update_basic_info"
    end
  end

  scope "(/:year/:season)", year: /\d{4}/,
       season: /spring|summer|autumn|winter/ do

    match "/applications/update_all_submissions",
          to: "pages#update_all_submissions", via: "patch",
          as: "update_all_submissions"
    match "/applications/approve_all_statuses",
          to: "pages#change_all_statuses", via: "patch",
          as: "approve_all_statuses", change: "approve"
    match "/applications/publish_all_statuses",
          to: "pages#change_all_statuses", via: "patch",
          as: "publish_all_statuses", change: "publish"
    match "/applications/drafts",
          to: "pages#submission_drafts", via: "get", as: "submission_drafts"
    match "/applications/accepted", to: "submissions#accepted",
          via: "get", as: "accepted_submissions"
    match "/projects/pending/publish_all",
          to: "projects#publish_all_pending", via: "patch",
          as: "publish_all_pending_projects"
    match "/evaluations", to: "evaluations#index", via: "get",
          as: "evaluations"

    match "/applications/:id/resume",
          to: "submissions#download_resume", via: "get", as: "download_resume"

    match "/admin/projects/new", to: "projects#admin_new", via: "get"

    resources :projects, shallow: true do

      collection do
        get "pending"
      end

      member do
        patch "update_status"
      end

      resources :submissions, path: 'applications', shallow: true do

        resources :evaluations, only: [:new, :create, :show]

        member do
          patch "accept_or_reject"
          patch "update_status"
        end

      end

    end

    match "/projects/:id", to: "projects#clone_project", via: "post"
  end

  devise_for :ldap_users, skip: [:sessions, :registrations]
  devise_for :local_users, skip: [:sessions]

  devise_scope :ldap_user do
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

  devise_scope :local_user do
    get "/register" => "devise/registrations#new", as: :new_user
    post "/register" => "devise/registrations#create", as: :create_user
    # Prevent users from deleting their own accounts.
    resource :registration,
    only: [:new, :create, :edit, :update],
    controller: "devise/registrations",
    as: :user_registration do
      get :cancel
    end
  end

  devise_for :local_users, controllers: { registrations: "registrations" }

  match "/users", to: "users#index", via: "get"
  match "/users/:id", to: "users#show", via: "get", as: "user"
  match "/users/:id", to: "users#update", via: "patch"
  match "/users/:id/my_projects", to: "users#my_projects_all", via: "get",
        as: "users_projects_all"
  match "/users/:id/my_applications", to: "users#my_submissions_all",
        via: "get", as: "users_submissions_all"
  match "/applications", to: "pages#submissions", via: "get", as: "submissions"
  match "/request_advisor_access", to: "pages#request_advisor_access",
        via: "get"
  match "/request_advisor_access", to: "pages#send_request_for_advisor_access",
        via: "post"
  match "/admin/projects", to: "projects#admin_create", via: "post"

  scope "/:year/:season", year: /\d{4}/,
       season: /spring|summer|autumn|winter/ do
    match "/my_projects", to: "users#my_projects", via: "get",
          as: "users_projects"
    match "/users/:id/my_applications", to: "users#my_submissions",
          via: "get", as: "users_submissions"
  end
end
