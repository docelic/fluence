get "/" do |env|
  env.redirect "/pages/"
end

get "/*" do |env|
  env.redirect "/pages/"
end

error 404 do |env|
  "Page not found"
end

error 403 do
  "Forbidden"
end
