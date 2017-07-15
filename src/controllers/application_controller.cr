class ApplicationController
  LAYOUT = "application.slang"

  getter env : HTTP::Server::Context

  def initialize(@env)
  end

  delegate :session, to: @env
  delegate :request, to: @env
  delegate :response, to: @env
  delegate :params, to: @env
  delegate :flash, to: @env
  delegate :cookies, to: @env.response

  def redirect_to(path, *args_to_hanle, **stuff_to_handle)
    @env.redirect path
  end

  def set_cookie(**cookie)
    cookies << HTTP::Cookie.new(**cookie)
  end

  def delete_cookie(name)
    set_cookie(name: name, value: "", expires: Time.now)
  end

  macro render_template(filename, path = "src/views")
    {% if filename.id.split("/").size > 2 %}
      Kilt.render("{{filename.id}}")
    {% else %}
      Kilt.render("#{{{path}}}/{{filename.id}}")
    {% end %}
  end

  macro render(filename, layout = true, path = "src/views", folder = __FILE__)
    # NOTE: content is basically yield rails layouts.
    {% if filename.id.split("/").size > 1 %}
      content = render_template("#{{{filename}}}", {{path}})
    {% else %}
      {% if folder.id.ends_with?(".ecr") %}
        content = render_template("#{{{folder.split("/")[-2]}}}/#{{{filename}}}", {{path}})
      {% else %}
        content = render_template("#{{{folder.split("/").last.gsub(/\_controller\.cr|\.cr/, "")}}}/#{{{filename}}}", {{path}})
      {% end %}
    {% end %}

    {% if layout && !filename.id.split("/").last.starts_with?("_") %}
      content = render_template("layouts/#{{{layout.class_name == "StringLiteral" ? layout : LAYOUT}}}", {{path}})
    {% end %}
    content
  end

  def set_login_cookies_for(username)
    Wikicr::USERS.transaction!(read: true) { |users| users[username].generate_new_token! }
    token = Wikicr::USERS[username].token.to_s
    set_cookie name: "user.name", value: username, expires: 14.days.from_now
    set_cookie name: "user.token", value: token, expires: 14.days.from_now
    puts "Generated cookies: #{cookies["user.name"]}, #{cookies["user.token"]}"
  end

  macro user_signed_in?
    session.string?("user.name")
  end

  macro user_name?
    session.string?("user.name")
  end

  macro current_user
    %name = user_signed_in?
    if (%name.nil?)
      Wikicr::USERS.default || raise "User not signed in"
    else
      Wikicr::USERS.find(%name)
    end
  end

  macro acl_permit!(perm)
    unless user_signed_in?
      if (name = cookies["user.name"]?) && (token = cookies["user.token"]?)
        if (user = Wikicr::USERS.auth_token?(name.value, token.value))
          session.string("user.name", user.name)
          set_login_cookies_for(user.name)
        else
          puts "Invalid cookies creditentials"
          delete_cookie "user.name"
          delete_cookie "user.token"
        end
      end
    end
    if Wikicr::ACL.permitted?(current_user, request.path, Acl::PERM[{{perm}}])
      puts "PERMITTED #{current_user.name} #{request.path} #{Acl::PERM[{{perm}}]}"
    else
      puts "NOT PERMITTED #{current_user.name} #{request.path} #{Acl::PERM[{{perm}}]}"
      #flash["danger"] = "You are not permitted to access this resource (#{request.path}, #{{{perm}}})."
      redirect_to "/pages/home", 302, {"flash.danger" => "You are not permitted to access this resource (#{request.path}, #{{{perm}}})."}
    end
  end
end

require "./**"
