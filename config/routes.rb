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

  get 'projects/:id/latestversion' => 'app_versions#latest_version'
  get '/jsHIsh8987HUfhugF1' => 'registrations#new'
  get '/install/:id' => 'app_versions#install'

  resources :users
  resources :token_authentications, :only => [:create, :destroy]
  resources :projects do
    resources :app_versions do
      get 'plist' => 'app_versions#plist'
    end
  end

  delete 'delete_by_version' => 'app_versions#delete_by_version'
  get ":guid" => "app_version#download_link"
end
