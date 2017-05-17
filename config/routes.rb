Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :weather_grid

  get "/subscriptions/cancel_subscription"  => "subscriptions#cancel_subscription"
  get "/subscriptions/update_card"          => "subscriptions#update_card"
  post "/subscriptions/update_card_details" => "subscriptions#update_card_details"

  resources :subscriptions


  root to: "home#index"
end
