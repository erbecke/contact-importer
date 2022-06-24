Rails.application.routes.draw do
  get 'welcome/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get "signup", to: "users#new"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :users, except: [:new]
  resources :imported_files
  resources :contacts, except: [:new]

  post "upload", to: "imported_files#upload"
  patch "imported_files/format_headers/:id", to: "imported_files#format_headers"
  # get "imported_files/format_headers/:id", to: "imported_files#format_headers"

  root 'welcome#index'

end
