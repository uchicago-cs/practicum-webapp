Practicum::Application.routes.draw do

  root 'pages#home'

  #resources :messages, except: :new
  #match "/projects/:id/request_changes", to: "messages#new", via: "get"

  resources :projects do
    resources :submissions do
      member do
        get "accept"
        get "reject"
      end
    end

    collection do
      get "pending"
    end

    member do
      get "edit_status"
    end

  end

  match "/projects/:id/edit_status", to: "projects#update_status", via: "patch"
  resources :evaluations, only: [:new, :create, :show, :index]
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

  match "/users", to: "users#index", via: "get"
  match "/users/:id", to: "users#show", via: "get", as: "user"
  match "/users/:id", to: "users#update", via: "patch"
  match "/submissions", to: "pages#submissions", via: "get"
  match "/projects/:project_id/submissions/:id/resume",
    to: "submissions#download_resume", via: "get", as: "download_resume"

end
