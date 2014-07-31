Practicum::Application.routes.draw do

  root 'pages#home'

  resources :projects, shallow: true do

    resources :submissions, path: 'applications', shallow: true do
      resources :evaluations, only: [:new, :create, :show, :index]
      member do
        patch "accept"
        patch "reject"
      end
    end
    collection do
      get "pending"
      resources :quarters
    end
    member do
      get "edit_status"
    end
  end

  match "/applications/:id",
  to: "submissions#download_resume", via: "get", as: "download_resume"
  # match "/applications/:id",
  #   to: "submissions#accept", via: "patch", as: "accept_submission"
  # match "/applications/:id",
  #   to: "submissions#reject", via: "patch", as: "reject_submission"

  match "/projects/:id/edit_status", to: "projects#update_status", via: "patch"
  devise_for :users, skip: [:sessions, :registrations]

  devise_scope :user do
    get "/signin" => "devise/sessions#new", as: :new_user_session
    post "/signin" => "devise/sessions#create", as: :user_session
    delete "/signout" => "devise/sessions#destroy", as: :destroy_user_session

    get "/signup" => "devise/registrations#new", as: :new_user_registration
    post "/signup" => "devise/registrations#create", as: :user_registration

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
  match "/applications", to: "pages#submissions", via: "get", as: "submissions"
  match "/projects/:id", to: "projects#clone_project", via: "post"
  match "/admin", to: "pages#admin", via: "get", as: "admin_dashboard"

end
