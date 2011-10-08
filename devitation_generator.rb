require 'rubygems'
require 'rufus/scheduler'
require 'httparty'
require 'json'
require 'xmlsimple'
require 'htmlentities'

# define uri of the deviation api
class DevitationApi
  include HTTParty
  base_uri 'http://localhost:8888/v1'
end


# define uri of vasttrafik stop list
class GetStopList
  include HTTParty
  base_uri 'http://vasttrafik.se/External_Services/TravelPlanner.asmx/'
end

# container for stop list with abiltiy to retrieve random stop
class StopList
  def initialize
    params = {"identifier" => "42b04690-659f-4659-b4b0-16aba2a9ad09"}
    out = GetStopList.post('/GetAllStops', :body => params)
    nested_xml = XmlSimple.xml_in(out.response.body)
    xml = HTMLEntities.new.decode(nested_xml['content'])
    puts xml
  end
end

class Deviation
  attr_accessor :comment, :scope, :latitude, :longitude, :transport, :source
  def to_hash()
    dev = Hash.new
    if @comment != nil
    dev['comment'] = @comment
    end
    if @scope != nil
    dev['scope'] = @scope
    end
    if @latitude != nil
    dev['latitude'] = @latitude
    end
    if @longitude != nil
    dev['longitude'] = @longitude
    end
    if @transport != nil
    dev['transport'] = @transport
    end
    if @source != nil
    dev['source'] = @source
    end
    return dev
  end
end



class DeviationGenerator
  def initialize(api)
    @scheduler = Rufus::Scheduler.start_new
    @api = api
  end

  def createDeviation(params)
    @scheduler.every '2s' do
      puts 'Creating new deviation ' << params.to_s
      out = DevitationApi.post('/deviations/', :body => params)
      id = JSON.parse( out.response.body )['id']
      puts 'Ceated deviation ' << id
    end
    @scheduler.join
  end
end

api = DevitationApi.new
StopList.new
generator = DeviationGenerator.new(api)
#dev = Deviation.new
#dev.comment = "hello"
#generator.createDeviation(dev.to_hash)
