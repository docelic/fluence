class ApplicationController
  module Redirect
    def redirect_to(path, status_code = 303)
      @env.redirect path, status_code
    end
  end
end
