require 'grape'

Dir["#{File.dirname(__FILE__)}/app/api/*.rb"].each { |f| require f }

module API
  class Root < Grape::API
    format :json
    prefix :api

    # Simple endpoint to get the current status of our API.
    get :status do
      { status: 'ok' }
    end

  end
end

# Mounting the Grape application
ParserAPI = Rack::Builder.new {
  map "/" do
    run API::Root
  end
}