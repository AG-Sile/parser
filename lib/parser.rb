require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'uri'
require 'json'

class Parser

  def parse_reviews(url)
    raise ArgumentError.new("lender_url was not provided") if url.nil?
    site = Nokogiri::HTML(open(url))
    # grab total review count
    reviews_count = site.css('a[class=reviews-count]').children.text.split(" ").first.to_i
    brand_id = site.css('a.reviewBtn.write-review').at('a').get_attribute('data-lenderreviewid')
    get_review_threads(reviews_count, brand_id).map(&:value).flatten
  end

  private

  def get_review_info(review)
      {
        :title => review['title'],
        :review_text => review['text'],
        :author_name => review['authorName'],
        :author_email => review['authorEmail'],
        :author_location => review['userLocation'],
        :is_recommended => review['isRecommended'],
        :review_likes => review['votesUp'],
        :review_dislikes => review['votesDown'],
        :overall_rating => review['primaryRating'],
        :secondary_rating => review['secondaryRatings'],
        :review_dateTime => review['submissionDateTime'] 
      }
  end 

  def get_review_threads(reviews_count, lender_reviews_id)
    base_url = "https://www.lendingtree.com/content/mu-plugins/lt-review-api/review-api-proxy.php?RequestType=&productType=&brandId=#{lender_reviews_id}&requestmode=reviews,stats,ratingconfig,propertyconfig&sortby=reviewsubmitted&sortorder=desc&pagesize=100"
    review_threads = (0..(reviews_count/100.0).floor).map do |pg_n|
      Thread.new do
        retries = 5
        uri = base_url + "&page=#{pg_n}"
        response = Net::HTTP.get_response(URI.parse(uri))
        begin
          reviews = JSON.parse(response.body)['result']['reviews']
          reviews.map { |r| get_review_info(r) }
        rescue NoMethodError => e
          e if retry_count <= 0
          retry_count -= 1
          retry
        end
      end
    end
  end
end

