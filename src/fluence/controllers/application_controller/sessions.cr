class ApplicationController
  module Session
    delegate :session, to: @env
  end
end
