RentPathApps::Application.routes.draw do
  root :to => 'welcome#index'

  devise_for :users, :controllers => {:registrations => "registrations"}, :skip => [:registrations]
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  devise_scope :user do
    get "/sign_in",  :to => "devise/sessions#new"
    get "/sign_up",  :to => "devise/registrations#new"
  end

  get '/jsHIsh8987HUfhugF1' => 'registrations#new'
  resources :users
  resources :token_authentications, :only => [:create, :destroy]
  resources :projects do
    resources :app_versions
  end

  get ":guid" => "app_version#download_link"
end
