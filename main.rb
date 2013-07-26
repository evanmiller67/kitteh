#!/usr/bin/env ruby
require "rubygems"
require "bundler"
require "logger"
require "yaml"
Bundler.require(:default)                 # Require the 'default' gems
Dir['./lib/*.rb'].each{ |f| require f }   # Load our libraries
include Rack::Utils

# Define system variables
LOCAL_IP            = Utilities.local_ip    # IP Address of the server

CONFIG              = YAML.load_file("config/settings.yaml")
DEBUG               = CONFIG["debug"]
SERVER_PORT         = CONFIG["server_port"]
PAGE_REFRESH_TIMER  = CONFIG["page_refresh_timer"]

# Define the logger
LOG = Logger.new STDOUT #("./log/devwall.log", "daily")
original_formatter = Logger::Formatter.new
LOG.formatter = proc { |severity, datetime, progname, msg|
  original_formatter.call(severity, datetime, progname, msg)
}
LOG.level = DEBUG ? Logger::DEBUG : Logger::INFO

# Main program loop
EventMachine.run do
  class App < Sinatra::Base
    set :static, true
    set :public_folder, "public"
    set :views,  "views"
    set :environment, DEBUG ? :development : :production
      
    # Set the WebSocket server URL
    before do
      @ws_server_url  = "ws://#{LOCAL_IP}:8095"
      @server_ip      = LOCAL_IP
      @server_port    = SERVER_PORT
    end    

    # 204
    get "/204" do
      haml :index
    end

    # main
    get "/" do
      haml :index
    end
  end
 
  @page_channel     = EM::Channel.new
  
  # Refresh the site every so often
  EventMachine::PeriodicTimer.new(PAGE_REFRESH_TIMER) { PageRefresh.run(@page_channel) }
  
  # Open the WebSocket and start accepting connections
  EventMachine::WebSocket.start(:host => UDPSocket.open { |s| s.connect(LOCAL_IP, 1); s.addr.last },
                                :port => 8095, :debug => DEBUG) do |ws|

    control_sid = page_sid = ""
    ws.onopen {
      # bind the incoming browser session to all the channels
      page_sid    = @page_channel.subscribe{ |msg| ws.send( {channel: 'page', data: msg }.to_json ) }
    }
    
    ws.onclose {
      # remove the binding between the browser session and the channels
      @page_channel.unsubscribe(page_sid)
    }

    ws.onerror { |e| LOG.error "A WebSocket error happened! #{e}" }
  end

  # You could also use Rainbows! instead of Thin.
  # Any EM based Rack handler should do.
  App.run!({:port => SERVER_PORT})
end
