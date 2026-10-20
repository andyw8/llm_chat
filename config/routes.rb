Rails.application.routes.draw do
  mount Poetry::Ui::Engine => "/poetry" # llms.txt + llms-full.txt (agent-facing docs)
  resources :chats do
    resources :messages, only: [ :create, :destroy ]
  end
  resources :models, only: [ :index ] do
    collection do
      post :refresh
    end
  end
  # Model ids are provider-scoped slugs that carry a slash
  # ("aion-labs/aion-3.5"), so the detail route takes the whole tail rather
  # than a single segment. format: false keeps dots in ids ("gpt-5.1") out of
  # the format parser.
  get "models/*id", to: "models#show", as: :model, format: false
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "chats#index"
end
