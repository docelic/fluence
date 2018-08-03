class ApplicationController
  module Redirect
    # TODO: improve that
    def redirect_to(path, *args_to_hanle, **stuff_to_handle)
      @env.redirect path
    end
  end
end
