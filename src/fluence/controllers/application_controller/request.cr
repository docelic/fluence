class ApplicationController
  module Request
    delegate :request, to: @env
  end
end
