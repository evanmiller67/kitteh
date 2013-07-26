# Kitteh 

This is an emergency kitten/puppy page. It generates urls and pushes them to your browser to retrieve calming pictures.

## Requirements

* Ruby 1.9.x
* Bundler is used to get all of the dependencies, so make sure you have it installed and you should be good to go.
* Browser that supports WebSockets (i.e. WebKit based)

## Installation

    $ gem install bundler  # Install bundler
    $ bundle install       # Install the rest of the necessary gems

## Usage

    $ ruby main.rb         # Start the server on port 5020

Now, just connect to http://localhost:5020 and it should start the whole thing off.  The index.html file gets downloaded
to your browser and it starts the connection to the WebSockets server.
