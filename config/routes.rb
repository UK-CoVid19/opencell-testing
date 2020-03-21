Rails.application.routes.draw do
  get 'home/index'
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 'samples/pendingdispatch', to: 'samples#pendingdispatch'
  get 'samples/pendingreceive', to: 'samples#pendingreceive'
  get 'samples/pendingprepare', to: 'samples#pendingprepare'
  get 'samples/pendingreadytest', to: 'samples#pendingreadytest'
  get 'samples/pendingtest', to: 'samples#pendingtest'#
  get 'samples/pendinganalyze', to: 'samples#pendinganalyze'
  get 'samples/dashboard', to: 'samples#dashboard', as: 'staff_dashboard'
  post 'samples/:id/ship', to: 'samples#ship', as: 'sample_ship'
  post 'samples/:id/receive', to: 'samples#receive', as: 'sample_receive'
  post 'samples/:id/prepare', to: 'samples#prepare', as: 'sample_prepare'
  post 'samples/:id/prepared', to: 'samples#prepared', as: 'sample_prepared'
  post 'samples/:id/tested', to: 'samples#tested', as: 'sample_tested'
  post 'samples/tested', to: 'samples#bulktested', as: 'sample_bulk_tested'
  post 'samples/:id/analyze', to: 'samples#analyze', as: 'sample_analyze'
  resources :samples
  devise_for :users
  resources :users
  root to: "home#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
