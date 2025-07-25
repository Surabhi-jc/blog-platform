Rails.application.routes.draw do
  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"


  #route for user signup
  post "/signup", to: "users#create"
  post "/login", to: "authentication#login"
  post "/blog", to: "blogs#create"
  patch "/blog/:id", to: "blogs#update"
  delete "/blog/:id", to: "blogs#destroy"
  get "/api/blog/show", to: "blogs#show"
  get "/blog/show_blog", to: "blogs#prefered_blogs"
  get "/api/blog/:id", to: "blogs#show_blog"

  resources :likes, only: [:create]
end
