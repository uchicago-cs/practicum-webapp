Dccc::Application.routes.draw do
  
  root 'pages#home'

  resources :projects do
    # Nest submissions routes within projects.
    resources :submissions do
      member do
        get "accept"
        get "reject"
      end
    end

    collection do
      # List of unapproved projects. Available only for admins.
      get "unapproved"
    end

    member do
      get "approve"
      get "disapprove"
    end
    
  end
  
  # Make devise resource routes for users controller, but do not use the
  # pre-packaged devise routes for sessions, registrations, and passwords.
  devise_for :users, skip: [:sessions, :registrations]#, :passwords]

  # Customized Devise routes for users.
  devise_scope :user do
    # Sessions.
    get "/signin" => "devise/sessions#new", as: :new_user_session
    post "/signin" => "devise/sessions#create", as: :user_session
    delete "/signout" => "devise/sessions#destroy", as: :destroy_user_session

    # Registrations. Will later be removed when we incorporate CNetID
    # authentication.
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

  # Users directory. Available only for admins.
  match "/users", to: "users#index", via: "get"
  match "/users/:id", to: "users#show", via: "get", as: "user"
  # Maybe the below routes will be available for admins. Users can
  # view their own information on their /users/:id page, and users
  # do not need to edit their profiles.

  match "/submissions", to: "pages#submissions", via: "get"

end
