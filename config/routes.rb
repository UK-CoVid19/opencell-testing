Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 'samples/pendingdispatch', to: 'samples#pendingdispatch'
  get 'samples/pendingreceive', to: 'samples#pendingreceive'
  get 'samples/pendingprepare', to: 'samples#pendingprepare'
  get 'samples/pendingtest', to: 'samples#pendingtest'
  post 'samples/:id/dispatch', to: 'samples#dispatch'
  post 'samples/:id/receive', to: 'samples#receive'
  post 'samples/:id/prepare', to: 'samples#prepare'
  post 'samples/:id/process', to: 'samples#process'
  post 'samples/:id/analyse', to: 'samples#analyse'
  resources :samples
  devise_for :users
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
