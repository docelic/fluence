class ApplicationController
  module Response
    delegate :response, to: @env
  end
end
