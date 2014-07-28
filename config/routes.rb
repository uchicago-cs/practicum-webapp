Practicum::Application.routes.draw do

  root 'pages#home'

  resources :projects do

    resources :submissions do
      resources :evaluations, only: [:new, :create, :show, :index]
      member do
        get "accept"
        get "reject"
      end
    end
    collection do
      get "pending"
      resources :quarters, only: [:show, :index, :edit, :update, :destroy]
    end
    member do
      get "edit_status"
    end
  end

  resources :quarters, only: [:new, :create]

  match "/projects/:project_id/submissions/:id/resume",
    to: "submissions#download_resume", via: "get", as: "download_resume"

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
  match "/submissions", to: "pages#submissions", via: "get"
  match "/projects/:id", to: "projects#clone", via: "post"

end
