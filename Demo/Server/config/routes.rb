Rails.application.routes.draw do
  resource :dashboards, only: :show
  resources :resources

  resource :modal, only: %i[new show] do
    collection do
      get :replace
    end
  end
  resource :navigation, only: :show do
    collection do
      get :second
      get :replace
    end
  end

  resource :configuration, only: :show

  root "dashboards#show"
end
