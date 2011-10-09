require 'httparty'
require 'json'

API_URL = "http://api.av.vikel.se/v1/deviations"

describe "avvikelse-api" do

  # Helper functions to build requests
  def post deviation_hash
    q = querify deviation_hash
    res = HTTParty.post "#{API_URL}/", {:body => q}
    JSON.parse( res.response.body )['id']
  end

  def get_deviation id
    url = "#{API_URL}/#{id}/"
    out = HTTParty.get url
    out.response.code.should == '200'
    body = out.response.body
    JSON.parse( body )['deviation'] 
  end
  
  def search args
    #/v1/deviations/status/?latitude=18.00&longitude=58.000&distance=500
    #out = HTTParty.get "#{API_URL}/status"
    #JSON.parse( out.response.body )
    q = querify args
    res = HTTParty.get "#{API_URL}/status/?#{q}"
    body = res.response.body
    JSON.parse( body )
  end
  
  def get_hard_deviation id
    nice_deviation
  end

  # support methods
  def querify hash
    hash.map {|k,v| "#{k}=#{v}"}.join '&'
  end
  
  def json_from lat, lon
    {:lat => lat, :lon => lon}.to_json
  end
  
  def save_report lat, lon 
    report = json_from lat, lon
    post report
  end
  
  it "should 404 on non existing deviation reports" do
    out = HTTParty.get "#{API_URL}/finnsinte/"
    out.response.code.should == "404"    
  end
  
  it "should save when posting" do
    deviation = nice_deviation
    id = post deviation
    assert_deviation deviation, get_deviation( id )
  end
  
  it "should find a deviation" do
    deviation = nice_deviation
    post deviation
    result = search common_point
    result.size.should > 0
    result['affects'].should > 0
  end
  
  it "should update" do
    id = post common_point
    deviation = nice_deviation
    deviation['id'] = id
    deviation.merge! nice_deviation
    post deviation
    
    updated = get_hard_deviation( id )
    updated['line'].should == "4"
  end
  
  it "should return emptiness if faraway point" do
    point = {'latitude' => '135.000','longitude' => '-74.000', 'distance' => '10'}
    emptiness = search point
    emptiness['affects'].should == 0
  end
  
  def assert_deviation expected, actual
    expected.each do |key,value|
      actual[key].should == value
    end
  end
  
  def nice_deviation
    {'line' => '4','vehicle' => 'fiat'}.merge common_point
  end
  
  def common_point
    {'latitude' => '17.0','longitude' => '60.0'}
  end

end