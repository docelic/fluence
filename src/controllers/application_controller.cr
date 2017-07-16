require "./application_controller/**"
require "./helpers/**"

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

  include Wikicr::Helpers::User
  include Wikicr::Helpers::Page

  getter env : HTTP::Server::Context

  def initialize(@env)
  end
end

require "./**"
