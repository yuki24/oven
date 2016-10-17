Oven.bake :ApiClient, destination: "tmp/" do
  format :json

  get :users,   "/api/v2/users"
  get :user,    "/api/v2/users/:id"
  post :user,   "/api/v2/users"
  patch :user,  "/api/v2/users/:id"
  delete :user, "/api/v2/users/:id"

  get :authentication, "/authentication", as: :authentication
end
