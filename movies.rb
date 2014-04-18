require 'sinatra'
require 'sinatra/reloader'
require 'typhoeus'
require 'json'
require 'pry'
require 'vcr'
require 'webmock'

VCR.configure do |c|
  c.cassette_library_dir = 'cassettes'
  c.hook_into :webmock # or :fakeweb
  c.default_cassette_options = { :record => :new_episodes }
end

def query_omdbapi url_path
  results = nil
  VCR.use_cassette('offline_playback') do
    results= Typhoeus.get("http://www.omdbapi.com" + url_path)
  end
  results
end


# A setup step to get rspec tests running.
configure do
  root = File.expand_path(File.dirname(__FILE__))
  set :views, File.join(root,'views')
end

get '/' do
	# redirect to('/results')
erb :search
end

get '/results' do
	# redirect to('/poster')
	search = params[:movie].gsub(" ", "+")
	results= query_omdbapi("/?s=#{search}")
	omdb_data = JSON.parse(results.body)
	# omdb_data.inspect

	@movies=omdb_data["Search"]

	erb :index
end


get '/movie/info/:imdbID' do
	search = params[:imdbID]
	results = query_omdbapi("/?i=#{params[:imdbID]}")
  omdb_data = JSON.parse(results.body)

 @poster=omdb_data["Poster"]
 @rating=omdb_data["Rated"]
 @release=omdb_data["Released"]
 @runtime=omdb_data["Runtime"]
 @genre=omdb_data["Genre"]
 @director=omdb_data["Director"]
 @actors=omdb_data["Actors"]
 @plot=omdb_data["Plot"]

erb :show
end

