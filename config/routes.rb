Rails.application.routes.draw do
  get 'home/index', as: 'home'
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad
  get 'samples/pendingdispatch', to: 'samples#step1_pendingdispatch', as: 'step1_pendingdispatch'
  get 'samples/pendingreceive', to: 'samples#step2_pendingreceive', as: 'step2_pendingreceive'
  get 'samples/pendingprepare', to: 'samples#step3_pendingprepare', as: 'step3_pendingprepare'
  get 'samples/pendingreadytest', to: 'samples#step4_pendingreadytest', as: 'step4_pendingreadytest'
  get 'samples/pendingtest', to: 'samples#step5_pendingtest', as: 'step5_pendingtest'
  get 'samples/pendinganalyze', to: 'samples#step6_pendinganalyze', as: 'step6_pendinganalyze'
  get 'samples/dashboard', to: 'samples#dashboard', as: 'staff_dashboard'
  post 'samples/dispatched', to: 'samples#step1_bulkdispatched', as: 'step1_sample_bulk_dispatched'
  post 'samples/received', to: 'samples#step2_bulkreceived', as: 'step2_sample_bulk_received'
  post 'samples/prepared', to: 'samples#step3_bulkprepared', as: 'step3_sample_bulkprepared'
  post 'samples/readytest', to: 'samples#step4_bulkreadytest', as: 'step4_sample_bulk_ready_test'
  post 'samples/tested', to: 'samples#step5_bulktested', as: 'step5_sample_bulk_tested'
  post 'samples/analysed', to: 'samples#step6_bulkanalysed', as: 'step6_sample_bulk_analysed'
  post 'users/create_staff', to: 'users#create_staff', as: 'create_staff'
  resources :plates do
    resources :tests, except: [:index] do 
      member do
        get 'analyse'
        patch 'confirm' 
      end 
    end 
  end
  get '/tests/complete', to: 'tests#complete'
  get '/tests/done', to: 'tests#done'
  resources :samples, except: [:update, :edit]

  devise_for :users
  resources :users, except: [:edit, :update]
  root to: "home#index"
  get 'privacy', to: 'home#privacy', as: 'privacy'
  get 'about', to: 'home#about', as: 'about'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
