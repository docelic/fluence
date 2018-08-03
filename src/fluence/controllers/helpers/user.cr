module Fluence::Helpers::User
  # The username+token are set into the cookies in order to allow future auto-login
  def set_login_cookies_for(username)
    Fluence::USERS.transaction!(read: true) { |users| users[username].generate_new_token! }
    token = Fluence::USERS[username].token.to_s
    set_cookie name: "user.name", value: username, expires: 14.days.from_now
    set_cookie name: "user.token", value: token, expires: 14.days.from_now
  end

  # If a cookie is set but the user is not signed in, try to use it and renew the cookie
  def uses_login_cookies
    unless user_signed_in?
      if (name = cookies["user.name"]?) && (token = cookies["user.token"]?)
        if (user = Fluence::USERS.auth_token?(name.value, token.value))
          session.string("user.name", user.name)
          set_login_cookies_for(user.name)
        else
          puts "Invalid cookies creditentials"
          delete_cookie "user.name"
          delete_cookie "user.token"
        end
      end
    end
  end

  # Nil if not signed in, else it returns the user name
  macro user_signed_in?
    session.string?("user.name")
  end

  # Nil if not signed in, else it returns the user name
  macro user_name?
    session.string?("user.name")
  end

  # If the user is connected return an `Fluence::User`, else the default user (guest)
  macro current_user
    %name = user_signed_in?
    if (%name.nil?)
      Fluence::USERS.default || raise "User not signed in"
    else
      Fluence::USERS.find(%name)
    end
  end

  macro acl_permit!(perm)
    uses_login_cookies
    if Fluence::ACL.permitted?(current_user, request.path, Acl::PERM[{{perm}}])
      puts "PERMITTED #{current_user.name} #{request.path} #{Acl::PERM[{{perm}}]}"
    else
      puts "NOT PERMITTED #{current_user.name} #{request.path} #{Acl::PERM[{{perm}}]}"
      flash["danger"] = "You are not permitted to access this resource (#{request.path}, #{{{perm}}})."
      redirect_to case request.path
	when "/pages/home"
		"/users/register"
	else
		"/pages/home"
	end
      return # Stop the action
    end
  end
end