Rails.application.routes.draw do
  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker




  #route for user signup
  post "/api/signup", to: "users#create"
  post "/api/login", to: "authentication#login"
  post "/blog", to: "blogs#create"
  patch "/blog/:id", to: "blogs#update"
  delete "/blog/:id", to: "blogs#destroy"
  get "/api/blog/show", to: "blogs#show"
  get "/api/blog/prefered_blogs", to: "blogs#prefered_blogs"
  get "/api/blog/:id", to: "blogs#show_blog"
  get "/api/blog/:id/is_liked", to: "blogs#is_liked"

  # resources :likes, only: [:create]
  post "/api/likes", to: "likes#create"
  delete "/api/likes", to: "likes#destroy"




  # Defines the root path route ("/")
  root to: "home#index"
  get '*path', to: 'home#index', constraints: ->(req) { !req.xhr? && req.format.html? }
end
