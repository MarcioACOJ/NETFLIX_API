Rails.application.routes.draw do
  resources :movies do
    collection do
      post :import
    end
  end
end
