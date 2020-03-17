Rails.application.routes.draw do
  get 'home/index'
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 'samples/pendingdispatch', to: 'samples#pendingdispatch'
  get 'samples/pendingreceive', to: 'samples#pendingreceive'
  get 'samples/pendingprepare', to: 'samples#pendingprepare'
  get 'samples/pendingtest', to: 'samples#pendingtest'
  post 'samples/:id/dispatch', to: 'samples#dispatch'
  post 'samples/:id/receive', to: 'samples#receive', as: 'sample_receive'
  post 'samples/:id/prepare', to: 'samples#prepare', as: 'sample_prepare'
  post 'samples/:id/process', to: 'samples#process', as: 'sample_process'
  post 'samples/:id/analyse', to: 'samples#analyse', as: 'sample_analyse'
  resources :samples
  devise_for :users
  resources :users
  root to: "home#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
