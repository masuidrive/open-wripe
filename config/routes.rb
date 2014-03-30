Wripe::Application.routes.draw do
  if Rails.env.production?
    offline = Rack::Offline.configure :cache_interval => 120 do
      %w(app).each do |c|
        cache ActionController::Base.helpers.asset_path("#{c}.css")
        cache ActionController::Base.helpers.asset_path("#{c}.js")
      end

      public_path = Rails.public_path
      Dir[public_path.join("fonts/*")].each do |file|
        cache '/'+Pathname.new(file).relative_path_from(public_path).to_s
      end

      Dir[public_path.join("images/*")  ].flatten.each do |file|
        cache '/'+Pathname.new(file).relative_path_from(public_path).to_s
      end
      
      # cache other assets
      network "*"
    end
    get "/application.manifest" => offline
  end

  resources :pages, :constraints => { :id => /\d{1}\w{5,32}/ }, :only => [:new, :create, :index] do
    collection do 
      get :archived
      get :calendar
      get :search
      get :tagged
      get :tags
    end
    resources :members, :controller => 'pages/members', :constraints => { :id => /\d+/ }
  end
  resources :pages, :constraints => { :id => /\d{1}\w{5,32}/ }, :except => [:new, :create, :index], :path => '/' do
    member do
      post :archive
      post :unarchive
    end
  end

  get 'calendar/exports/:key', :constraints => { :key => /\w+/ }, :controller => 'calendar', :action => 'export'
  post 'calendar/generate_export_key', :controller => 'calendar', :action => 'generate_export_key'

  resources :messages
  resources :helps, :constraints => { :id => /\w+/ }, :only => [:destroy] do
    collection do 
      post :reset
    end
  end

  get 'app' => 'app#index', :as => 'home'

  get 'sign_out' => 'sessions#destroy', :as => 'sign_out'
  get 'session(.:format)' => 'sessions#show'
  if %w(test development).include?(Rails.env)
    get 'sessions/test' => 'sessions#test'
  end

  resource :settings

  namespace :fbauth do
    get 'sign_in'
    get 'callback'
  end

  namespace :ghauth do
    get 'sign_in'
    get 'callback'
  end

  namespace :dropbox_auth do
    get 'sign_in'
    get 'callback'
  end

  namespace :evernote_auth do
    get 'sign_in'
    get 'connect'
    get 'callback'
  end

  get 'export/:action', :controller => 'exports'

  resources :feedbacks

  get 'stats(.:format)' => 'stats#index'

end
