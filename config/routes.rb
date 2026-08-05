# require 'sidekiq/web'

# Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
#   ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Rails.application.config.synchronist_username)) &
#     ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Rails.application.config.synchronist_password))
# end

Rails.application.routes.draw do
  root "dashboard#index"

  resources :syncs, only: [:index, :show]
  resources :received_files, only: :index
  resource :config, only: [:edit, :update]

  namespace :sender do
    resources :payloads, only: :index
  end

  namespace :receiver do
    resources :payloads, only: :index
  end

  # mount Sidekiq::Web => '/sidekiq', as: :sidekiq
end
