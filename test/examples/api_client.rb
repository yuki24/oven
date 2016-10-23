Oven.bake :ApiClient, destination: "tmp/" do
  format :json

  get :users,   "/api/v2/users"
  get :user,    "/api/v2/users/:id"
  post :user,   "/api/v2/users"
  patch :user,  "/api/v2/users/:id"
  put :user,  "/api/v2/users/:id", as: :put_user
  delete :user, "/api/v2/users/:id"
  head :users, "/api/v2/users"
  options :users, "/api/v2/users"

  get :authentication, "/authentication", as: :authentication
end
