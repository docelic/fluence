class ApplicationController
  module Cookies
    delegate :cookies, to: @env.response

    def set_cookie(**cookie)
      cookies << HTTP::Cookie.new(**cookie)
    end

    def delete_cookie(name)
      set_cookie(name: name, value: "", expires: Time.now)
    end
  end
end
