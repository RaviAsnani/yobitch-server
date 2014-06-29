Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  namespace :api, :defaults => {:format => 'json'}  do
    namespace :v1 do
      put 'users' => 'users#update'
      resources :users, only: [:create] do
        collection do
          post 'sync_contacts'
          post 'add_friend'
          post 'send_message'
        end
      end
    end
  end

end
