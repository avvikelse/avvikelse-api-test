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
    # params = {"identifier" => "42b04690-659f-4659-b4b0-16aba2a9ad09"}
    # out = GetStopList.post('/GetAllStops', :body => params)
    # nested_xml = XmlSimple.xml_in(out.response.body)
    # xml = HTMLEntities.new.decode(nested_xml['content'])
    # puts xml
    # xml['root']['all_stops']['items']['item'].each do |item|
    # puts item
    # end
  end
end



class Deviation
  # needs to be backed up with some "real data" -> vasttrafik!?
  @@comments = ["olycka", "motor skada", "vet inte vaför", "alltid versenat"]
  @@lines = [ "1", "2", "3"  ]
  @@vehicles = [ "Oscar", "Hannah"  ]
  @@coords = [[ "11.981211", "57.709792"], [ "11.981300", "58.709792"] ]
  @@transports = ["BUS", "TRAIN", "SUBWAY"]

  attr_accessor :comment, :line, :vehicle, :latitude, :longitude, :transport, :source

  def initialize(randomize)
    if randomize == true
    @comment = @@comments.sample
    @line = @@lines.sample
    @vehicle = @@vehicles.sample
    coord = @@coords.sample
    @latitude = coord[0]
    @longitude = coord[1]
    @transport = @@transports.sample
    @source = "crowd"
    end
  end

  def to_hash()
    dev = Hash.new
    if @comment != nil
    dev['comment'] = @comment
    end
    if @line != nil
    dev['line'] = @line
    end
    if @vehicle != nil
    dev['vehicle'] = @vehicle
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
  def initialize(api, interval = '5s')
    @scheduler = Rufus::Scheduler.start_new
    @api = api
    @interval = interval
  end

  def createRandomDeviation
    @scheduler.every @interval do
      dev = Deviation.new(true)
      params = dev.to_hash
      puts 'Creating new deviation ' << params.to_s
      out = DevitationApi.post('/deviations/', :body => params)
      id = JSON.parse( out.response.body )['id']
      puts 'Ceated deviation ' << id
    end
    @scheduler.join
  end
end

# put things together
api = DevitationApi.new
generator = DeviationGenerator.new(api)
generator.createRandomDeviation()
