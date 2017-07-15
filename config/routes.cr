class Router
  #macro get(route, controller, method)
  #  ::get({{route}}) { |env| {{controller}}.new(env).{{method.id}}() }
  #end
  {% for verb in {:get, :post, :delete, :patch, :put, :head} %}
    macro {{verb.id}}(route, controller, method)
      ::{{verb.id}}(\{{route}}) { |env| \{{controller}}.new(env).\{{method.id}}() }
    end
  {% end %}
end

Router.get "/", HomeController, :index
Router.get "/sitemap", PagesController, :sitemap
Router.get "/pages/search", PagesController, :search
Router.get "/pages/*path", PagesController, :show
Router.post "/pages/*path", PagesController, :update
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
