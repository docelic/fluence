class ApplicationController
  module Params
    delegate :params, to: @env
  end
end
