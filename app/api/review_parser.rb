require './lib/parser'

module API
  class ReviewParser < Grape::API
    version 'v1', using: :header, vendor: 'me'
    format :json
    prefix :api

    helpers do
      def with_error_handling
        begin
          yield
        rescue Errno::ENOENT, SocketError => e 
          error!("Provided Lender URL cannot be reached, make sure to include full, encoded URL", 400)
        rescue StandardError => e 
          error!("Internal server error", 500)
        end
      end
    end

    desc 'Simple endpoint to get the current status of our API.'
    get :status do
      { status: 'Ok' }
    end

    desc 'Get Reviews from a LendingTree URL'
    params do
      requires :lender_url, type: String, desc: 'the base url for the lender'
    end
    get 'review_parser/:lender_url', requirements: { lender_url: /.*/ } do
      with_error_handling { Parser.new.parse_reviews(params[:lender_url]) }
    end
  end
end