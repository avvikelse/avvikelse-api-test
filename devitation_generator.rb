require 'rubygems'
require 'rufus/scheduler'
require 'httparty'
require 'json'
require 'xmlsimple'
require 'htmlentities'



# define uri of the deviation api
class DevitationApi
  include HTTParty
  #base_uri 'http://localhost:8888/v1'
  base_uri 'http://api.av.vikel.se/v1'
end



# define uri of vasttrafik stop list
class GetStopList
  include HTTParty
  base_uri 'https://api.trafiklab.se/samtrafiken/resrobot'  
end


class Stop
  attr_accessor :name, :x, :y
  
  def initialize(name, x, y)
    @name = name
    @x = x
    @y = y
  end
end

# container for stop list with abiltiy to retrieve random stop
class StopList
  @stops = Array.[]
  
  def initialize
    params = {"key" => "8300d2f62d1a0db69a7c9117dbd8768f",
             "centerX" => "11.981211",
             "centerY" => "57.709792",
             "radius"  => "30000", # max radius
             "coordSys" => "WGS84",
             "apiVersion" => "2.1" }
    out = GetStopList.get('/StationsInZone', :query => params)
    puts out
    xml = XmlSimple.xml_in(out.response.body)
    tmp_stops = []
    xml['location'].each do |item|
        stop = Stop.new(item['name'][0], item['x'], item['y'])
        tmp_stops.push(stop)       
    end
    @stops = tmp_stops
  end
  
  def random_stop
    return @stops.sample
  end
end



class Deviation
  # needs to be backed up with some "real data" -> vasttrafik!?
  @@comments = ["olycka", "motor skada", "vet inte vafor", "alltid versenat"]
  @@transports = ["BUS", "TRAIN", "SUBWAY"]
  @@stops = StopList.new

  attr_accessor :comment, :line, :vehicle, :latitude, :longitude, :transport, :source

  def initialize(randomize)
    if randomize == true 
      stop = @@stops.random_stop
      @comment = stop.name << " - " << @@comments.sample
      @line = rand(10) + 1 
      @vehicle = rand(500) + 1
      @latitude = stop.x
      @longitude = stop.y
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
  def initialize(api, interval = '1s')
    @scheduler = Rufus::Scheduler.start_new
    @api = api
    @interval = interval
  end

  def createRandomDeviation
    @scheduler.every @interval do
      begin
         dev = Deviation.new(true)
         params = dev.to_hash
         puts 'Creating new deviation ' << params.to_s
         out = DevitationApi.post('/deviations/', :body => params)
         id = JSON.parse( out.response.body )['id']
         puts 'Ceated deviation ' << id
      rescue Exception => msg  
         puts "Something went wrong"  
      end 
    end
    @scheduler.join
  end
end

# put things together
api = DevitationApi.new
generator = DeviationGenerator.new(api)
generator.createRandomDeviation()
