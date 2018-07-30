Rails.application.routes.draw do   
  resources :snippets

  root to: 'snippets#stream'

  get 'snippet/:slug', to: 'snippets#show'
  get 'snippet/:slug/stream', to: 'snippets#stream'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  mount ActionCable.server => '/cable' 
  
end
