Oven.bake :ApiClient, destination: "tmp/" do
  format :json

  get :users, "/api/v2/users"
  get :user, ->(id) { "/api/v2/users/#{id}" }
  post :user, "/api/v2/users"
  patch :user, ->(id) { "/api/v2/users/#{id}" }
  delete :user, ->(id) { "/api/v2/users/#{id}" }

  get :authentication, "/authentication", as: :authentication
end
