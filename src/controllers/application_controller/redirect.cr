class ApplicationController
  module Redirect
    def redirect_to(path, status_code = 302)
      @env.redirect path, status_code
    end
  end
end
