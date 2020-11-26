require 'sidekiq/web'
Rails.application.routes.draw do
  resources :clients, except: [:destroy] do
    member do
      get 'stats'
      post 'testhook'
      get 'samples'
    end
  end
  get 'home/index', as: 'home'
  devise_for :admin_users, ActiveAdmin::Devise.config

  constraints(ip: Regexp.new(ENV['PERMITTED_IP'])) do
    ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad
    mount Sidekiq::Web => '/sidekiq'
  end

  get 'samples/pendingplate', to: 'samples#pending_plate', as: 'pending_plate'
  get 'samples/pendingprepare', to: 'samples#step3_pendingprepare', as: 'step3_pendingprepare'
  get 'samples/pendingreadytest', to: 'samples#step4_pendingreadytest', as: 'step4_pendingreadytest'
  get 'samples/pendingtest', to: 'samples#step5_pendingtest', as: 'step5_pendingtest'
  get 'samples/pendinganalyze', to: 'samples#step6_pendinganalyze', as: 'step6_pendinganalyze'
  get 'samples/dashboard', to: 'samples#dashboard', as: 'staff_dashboard'
  get 'samples/new_retest', to: 'samples#new_retest', as: 'new_retest'
  post 'samples/new_retest', to: 'samples#retest_after', as: 'retest_after'
  post 'samples/prepared', to: 'samples#step3_bulkprepared', as: 'step3_sample_bulkprepared'
  post 'samples/readytest', to: 'samples#step4_bulkreadytest', as: 'step4_sample_bulk_ready_test'
  post 'samples/tested', to: 'samples#step5_bulktested', as: 'step5_sample_bulk_tested'
  post 'samples/analysed', to: 'samples#step6_bulkanalysed', as: 'step6_sample_bulk_analysed'
  post 'users/create_staff', to: 'users#create_staff', as: 'create_staff'
  resources :labgroups
  resources :labs

  resources :plates, except: [:edit, :update, :destroy] do
    resources :tests, except: [:index, :edit, :update, :destroy] do
      member do
        get 'analyse'
        patch 'confirm'
      end 
      collection do
        post 'createfile'
      end
    end
  end
  get '/tests/complete', to: 'tests#complete'
  get '/tests/done', to: 'tests#done'
  resources :samples, except: [:update, :edit] do
    member do
      patch 'reject'
      post 'retestpositive'
      post 'retestinconclusive'
    end
  end

  devise_for :users
  resources :users, except: [:edit, :update] do
    collection do
      get 'session_labgroup'
      post 'session_labgroup_set'
      get 'session_lab'
      post 'session_lab_set'
    end
  end
  root to: "home#index"
  get 'privacy', to: 'home#privacy', as: 'privacy'
  get 'about', to: 'home#about', as: 'about'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
