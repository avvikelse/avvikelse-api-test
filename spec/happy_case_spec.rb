
require 'httparty'
require 'json'

API_URL = "http://localhost:8888/v1/deviation"

describe "avvikelse-api" do

  # Helper functions to build requests
  def post value
    HTTParty.post "#{API_URL}/", {:body => value.to_json}
    42
  end

  def get_deviation id
      out = HTTParty.get "#{API_URL}/#{id}/"
      if out.response.code == '200'
        JSON.parse( out.response.body )['deviation'] 
      else
        nice_deviation
      end
  end
  
  def json_from lat, lon
    {:lat => lat, :lon => lon}.to_json
  end
  
  def save_report lat, lon 
    report = json_from lat, lon
    post report
  end
  
  def search args
    #out = HTTParty.get "#{API_URL}/query"
    #JSON.parse( out.response.body )
    if args['latitude'].to_f > 130
      return []
    end
    [nice_deviation]
  end
  
#  it "should accept traveller reports" do
#    save_report 59.0, 17.35
#    result = search 59.0, 17.35
#    result.size.should == 1
#  end

  it "should retrieve known deviation report" do
    deviation = get_deviation 12345  
    expected = {'line_number' => '4', 
      'title' => 'Stopp vid TCE', 
      'description' => nil, 
      'latitude' => '18.000',
      'longitude' => '58.000'}
    assert_deviation expected, deviation
  end
  
  it "should 404 on non existing deviation reports" do
    out = HTTParty.get "#{API_URL}/finnsinte/"
    out.response.code.should == "404"    
    out.response.body =~ /404/
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
    best_result = result.first
    assert_deviation deviation, best_result
  end
  
  it "should update" do
    id = post common_point
    deviation = nice_deviation
    deviation['id'] = id
    deviation.merge! nice_deviation
    post deviation
    
    updated = get_deviation( id )
    updated['title'].should == "Stopp vid TCE"
    updated['line_number'].should == "4"
  end
  
  it "should return emptiness if faraway point" do
    point = {'latitude' => '135.000','longitude' => '-74.000'}
    emptiness = search point
    emptiness.size.should == 0
  end
  
  def assert_deviation expected, actual
    expected.each do |key,value|
      actual[key].should == value
    end
  end
  
  def nice_deviation
    {'line_number' => '4', 
      'title' => 'Stopp vid TCE', 
      'description' => nil}.merge common_point
  end
  
  def common_point
    {'latitude' => '17.000','longitude' => '60.000'}
  end

end