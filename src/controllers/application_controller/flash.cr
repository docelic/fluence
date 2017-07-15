class ApplicationController
  module Flash
    delegate :flash, to: @env
  end
end
