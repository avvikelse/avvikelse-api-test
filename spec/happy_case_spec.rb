
require 'httparty'
require 'json'

API_URL = "http://localhost:8888/v1/deviation"

describe "avvikelse-api" do
 
  # Helper functions to build requests
  def post value
    HTTParty.post "#{API_URL}", {:body => value}
  end

  def get_deviation id
      out = HTTParty.get "#{API_URL}/#{id}/"
      JSON.parse( out.response.body ) 
  end
  
  def json_from lat, lon
    {:lat => lat, :lon => lon}.to_json
  end
  
  def save_report lat, lon 
    report = json_from lat, lon
    post report
  end
  
  def search args
      out = HTTParty.get "#{API_URL}/query"
      JSON.parse( out.response.body )
  end
  
#  it "should accept traveller reports" do
#    save_report 59.0, 17.35
#    result = search 59.0, 17.35
#    result.size.should == 1
#  end

  it "retrieve known deviation" do
    deviation = get_deviation 1234  
    deviation['deviation']['line_number'].should == '4'
  end

end