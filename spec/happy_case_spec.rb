
require 'httparty'

API_URL = "http://94.247.169.81"

describe "avvikelse-api" do
  def post value
    #HTTParty.post "#{API_URL}/V1/Deviations", {:body => value}
  end

  def get key
    #HTTParty.get "#{API_URL}/V1/Deviations"
  end
  
  def json_from x, y
    
  end
  
  def save_report x, y 
    report = json_from x, y
    post report
  end
  
  def search x, y
    q = json_from x, y
    get q
  end
  
  it "should accept traveller reports" do
    save_report 59.0, 17.35
    result = search 59.0, 17.35
    result.size.should == 1
  end
end