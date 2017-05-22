Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'landing#index', as: :landing_page

  get '/auth/facebook', as: :facebook_login
  get '/auth/facebook/callback', to: "sessions#create", as: :facebook_callback

  resources :sessions, only: [:create]

  get '/sign_up', to: 'sign_up#new'
  post '/sign_up', to: 'sign_up#create'
  get 'signout', to: 'sessions#destroy', as: 'signout'

  get '/:username/dashboard', to: 'users#show', as: :dashboard
  get '/:username/dashboard/edit', to: 'users#edit', as: :dashboard_edit
  patch '/:username/dashboard/edit', to: 'users#update', as: :dashboard_patch

  get '/:username/dashboard/change_password', to: 'passwords#edit', as: :password_edit

  resources :folders, only: [:index]

  namespace :users, path: ":username" do
    resources :folders, only: [:new, :create]
  end

  get '/:username/*route/binary_new', to: 'users/folders/binaries#new', as: :new_binary
  get '/:username/*route/:binary_name', to: 'users/folders/binaries#show', format: true
  post '/:username/*route', to: 'users/folders/binaries#create', as: :binaries
  #send url of nested folders to folders#new?

  get '/:username/*route', to: 'users/folders#show', as: :folder
end
