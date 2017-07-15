require "./application_controller/*"
require "./lib_controller"

class ApplicationController
  LAYOUT = "application.slang"
  include ApplicationController::Render
  include ApplicationController::Session
  include ApplicationController::Request
  include ApplicationController::Response
  include ApplicationController::Params
  include ApplicationController::Flash
  include ApplicationController::Cookies
  include ApplicationController::Redirect

  getter env : HTTP::Server::Context

  def initialize(@env)
  end

  include LibController
end

require "./**"
