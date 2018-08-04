class Router
  {% for verb in {:get, :post, :delete, :patch, :put, :head} %}
    macro {{verb.id}}(route, controller, method)
      ::{{verb.id}}(\{{route}}) do |env|
        context = \{{controller}}.new(env)
        # puts "Before init"
        # pp env.request.cookies
        # pp env.response.cookies
        context.cookies.fill_from_headers(env.request.headers)
        # puts "After init"
        # pp env.request.cookies
        # pp env.response.cookies
        output = context.\{{method.id}}()
        # puts "After controller"
        # pp env.request.cookies
        # pp env.response.cookies
        #context.cookies.add_response_headers(env.response.headers)
        output
      end
    end
  {% end %}
end

Router.get "/", HomeController, :index
Router.get "/sitemap", PagesController, :sitemap

# /pages/
Router.get "/pages/search", PagesController, :search
Router.get "/pages/*path", PagesController, :show
Router.post "/pages/*path", PagesController, :update
Router.delete "/pages/*path", PagesController, :delete
# /p/ shorthand
Router.get "/p/search", PagesController, :search
Router.get "/p/*path", PagesController, :show
Router.post "/p/*path", PagesController, :update
Router.delete "/p/*path", PagesController, :delete

Router.get "/users/login", UsersController, :login
Router.post "/users/login", UsersController, :login_validates
Router.get "/users/register", UsersController, :register
Router.post "/users/register", UsersController, :register_validates
Router.get "/admin/users", AdminController, :users_show
Router.post "/admin/users/create", AdminController, :user_create
Router.post "/admin/users/delete", AdminController, :user_delete
Router.get "/admin/acls", AdminController, :acls_show
Router.post "/admin/acls/update", AdminController, :acl_update
Router.post "/admin/acls/create", AdminController, :acl_create
Router.post "/admin/acls/delete", AdminController, :acl_delete
