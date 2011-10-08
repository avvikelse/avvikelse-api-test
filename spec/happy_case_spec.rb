
require 'httparty'

API_URL = "http://94.247.169.81"

describe "avvikelse-api" do
  def post value
    #HTTParty.post "#{API_URL}/V1/Deviations", {:body => value}
  end

  def get key
    #HTTParty.get "#{API_URL}/V1/Deviations"
  end
  
  def json_from lat, lon
    
  end
  
  def save_report lat, lon 
    report = json_from lat, lon
    post report
  end
  
  def search lat, lon
    q = json_from lat, lon
    get q
  end
  
  it "should accept traveller reports" do
    save_report 59.0, 17.35
    result = search 59.0, 17.35
    result.size.should == 1
  end
end