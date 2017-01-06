Oven.bake :ApiClient, object_mapping: 'test/examples/models.yml', destination: "tmp/" do
  format :json

  get :users,     "/api/v2/users",     class: 'Array(User)'
  get :user,      "/api/v2/users/:id", class: 'User'
  head :users,    "/api/v2/users"
  post :user,     "/api/v2/users",     class: 'User'
  patch :user,    "/api/v2/users/:id", class: 'User'
  put :user,      "/api/v2/users/:id", class: 'User', as: :put_user
  delete :user,   "/api/v2/users/:id"
  options :users, "/api/v2/users"

  get :authentication, "/authentication", as: :authentication
end
