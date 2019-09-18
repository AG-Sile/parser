require 'spec_helper'

describe Parser do 
  subject { Parser.new }
  let(:html_instance) { double }
  let(:noko_instance) { double }
  let(:request_to_be_stubbed) { "https://www.lendingtree.com/content/mu-plugins/lt-review-api/review-api-proxy.php?RequestType=&brandId=12345&page=0&pagesize=100&productType=&requestmode=reviews,stats,ratingconfig,propertyconfig&sortby=reviewsubmitted&sortorder=desc" }

  describe "happy path" do
    let(:dateTimeNow) { DateTime.now }
    let(:request_to_be_stubbed_2) { "https://www.lendingtree.com/content/mu-plugins/lt-review-api/review-api-proxy.php?RequestType=&brandId=12345&page=1&pagesize=100&productType=&requestmode=reviews,stats,ratingconfig,propertyconfig&sortby=reviewsubmitted&sortorder=desc" }

    let(:fake_good_response) do
      {
        'result' => {
          'reviews' => [{
            'title' => "The REVIEW",
            'text' => "Just look at how awesome my review is!!",
            'authorName' => "Mr Kittens",
            'authorEmail' => "kittens@example.com",
            'userLocation' => "Dark Alley, IL",
            'isRecommended' => "true",
            'votesUp' => "9001",
            'votesDown' => "0",
            'primaryRating' => "5",
            'secondaryRatings' => {},
            'submissionDateTime' => dateTimeNow
          }]
        }
      }
    end
    
    it "is happy" do
      allow(subject).to receive(:open).and_return(:html_instance)
      allow(Nokogiri::HTML::Document).to receive(:parse).with(:html_instance, nil, nil, 2145).and_return(noko_instance)
      noko_instance.stub_chain(:css, :children, :text).and_return("10 Reviews")
      noko_instance.stub_chain(:css, :at, :get_attribute).and_return("12345")

      stub_request(:get, request_to_be_stubbed)
        .with(
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host'=>'www.lendingtree.com',
          'User-Agent'=>'Ruby'
           }
        )
        .to_return(status: 200, body: fake_good_response.to_json)
      subject.parse_reviews("www.example.com").should eq([{
        :title=>"The REVIEW", 
        :review_text=>"Just look at how awesome my review is!!", 
        :author_name=>"Mr Kittens", 
        :author_email=>"kittens@example.com", 
        :author_location=>"Dark Alley, IL", 
        :is_recommended=>"true", 
        :review_likes=>"9001", 
        :review_dislikes=>"0", 
        :overall_rating=>"5", 
        :secondary_rating=>{}, 
        :review_dateTime=>dateTimeNow.to_s
      }])

    end

    it "is happy with multiple pages" do
      allow(subject).to receive(:open).and_return(:html_instance)
      allow(Nokogiri::HTML::Document).to receive(:parse).with(:html_instance, nil, nil, 2145).and_return(noko_instance)
      noko_instance.stub_chain(:css, :children, :text).and_return("101 Reviews")
      noko_instance.stub_chain(:css, :at, :get_attribute).and_return("12345")

      stub_request(:get, request_to_be_stubbed)
        .with(
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host'=>'www.lendingtree.com',
          'User-Agent'=>'Ruby'
           }
        )
        .to_return(status: 200, body: fake_good_response.to_json)
      stub_request(:get, request_to_be_stubbed_2)
        .with(
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host'=>'www.lendingtree.com',
          'User-Agent'=>'Ruby'
           }
        )
        .to_return(status: 200, body: fake_good_response.to_json)
      subject.parse_reviews("www.example.com").should eq([{
        :title=>"The REVIEW", 
        :review_text=>"Just look at how awesome my review is!!", 
        :author_name=>"Mr Kittens", 
        :author_email=>"kittens@example.com", 
        :author_location=>"Dark Alley, IL", 
        :is_recommended=>"true", 
        :review_likes=>"9001", 
        :review_dislikes=>"0", 
        :overall_rating=>"5", 
        :secondary_rating=>{}, 
        :review_dateTime=>dateTimeNow.to_s
      }])

    end
  end

  describe "the api returns an error" do 
    it "is sad" do
      allow(subject).to receive(:open).and_return(:html_instance)
      allow(Nokogiri::HTML::Document).to receive(:parse).with(:html_instance, nil, nil, 2145).and_return(noko_instance)
      noko_instance.stub_chain(:css, :children, :text).and_return("10 Reviews")
      noko_instance.stub_chain(:css, :at, :get_attribute).and_return("12345")

      stub_request(:get, request_to_be_stubbed)
        .with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host'=>'www.lendingtree.com',
            'User-Agent'=>'Ruby'
          }
        )
      .to_return(status: 500, body: {}.to_json)
      expect{subject.parse_reviews("www.example.com")}.to raise_error
    end
  end
end