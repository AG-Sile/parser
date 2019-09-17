module API
  class Root < Grape::API
    format :json
    prefix :api
  end
end