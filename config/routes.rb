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
  get "/user/me", to: "users#me"
  put "/user/update", to: "users#update"

  post "/api/login", to: "authentication#login"
  post "/api/blog", to: "blogs#create"
  put "/blog/:id", to: "blogs#update"
  delete "/api/blog/:id", to: "blogs#destroy"
  get "/api/blog/show", to: "blogs#show"
  get "/api/blog/prefered_blogs", to: "blogs#prefered_blogs"
  get "/api/blog/:id", to: "blogs#show_blog"
  get "/api/blog/:id/is_liked", to: "blogs#is_liked"
  get "/user/my_blogs", to: "blogs#my_blogs"
  patch "/api/blog/:id/restore", to: "blogs#restore"

  #admin route
  namespace :admin do
    get "blogs/active", to: "blogs#active"
    get "blogs/deleted", to: "blogs#deleted"
  end


  # resources :likes, only: [:create]
  post "/api/likes", to: "likes#create"
  delete "/api/likes", to: "likes#destroy"

  get "/api/tags", to: "tags#show_tags"

  post "/blog/:id/comment", to: "comments#create"
  delete "/api/blog/:id/comments/:comment_id", to: "comments#destroy"



  # Defines the root path route ("/")
  root to: "home#index"
  get '*path', to: 'home#index', constraints: ->(req) { !req.xhr? && req.format.html? }
end
