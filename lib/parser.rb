require 'nokogiri'
require 'open-uri'

class Parser

  def parse_reviews(url)
    
    raise ArgumentError.new("lender_url was not provided") if url.nil?
    site = Nokogiri::HTML(open(url))
    # grab total review count
    reviews_count = site.css('a[class=reviews-count]').children.text.split(" ").first.to_i
    pages = reviews_count
    review_pages_threads = (1..(reviews_count/10.0).ceil).map do |pg_n|
      Thread.new do 
        new_url = url + "?sort=b3ZlcmFsbHJhdGluZ19kZXNj&pid=#{pg_n}"
        Nokogiri::HTML(open(new_url)).css('div.col-xs-12.mainReviews')
      end
    end
    review_infos = review_pages_threads.map do |t|
      tvalue = t.value
      tvalue.map { |review| get_review_info(review) }
    end.flatten
    review_infos
  end

  private

  def get_review_info(review)
      {
        :stars => review.css('div.numRec').text[/[\d]/].to_i,
        :title => review.css('p.reviewTitle').text,
        :review_text => review.css('p.reviewText').text,
        :reviewer_name => review.css('p.consumerName').children.first.text.strip,
        :reviewer_location => review.css('p.consumerName').children.last.text[5..-1].strip,
        :review_date => review.css('p.consumerReviewDate').text[12..-1].strip,
        :review_likes => review.css('span.likes').text.to_i,
        :review_dislikes => review.css('span.dislikes').text.to_i
      }
  end 
end

