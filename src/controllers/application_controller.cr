class ApplicationController < Amber::Controller::Base
  LAYOUT = "application.slang"

  macro user_signed_in?
    session["username"]
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
