require './lib/parser'
module ReviewParser
  class API < Grape::API
    version 'v1', using: :header, vendor: 'me'
    format :json
    prefix :api

    desc 'Get Reviews from a LendingTree URL'
    params do
      requires :lender_url, type: String, desc: 'the base url for the lender'
    end
    get 'review_parser/:lender_url', requirements: { lender_url: /.*/ } do
      Parser.new.parse_reviews(params[:lender_url])
    end
  end
end