require 'rubygems'
require 'sinatra'
require 'haml'
require 'data_mapper'

set :haml, :format => :html5


DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_AMBER_URL'] || "sqlite3://#{Dir.pwd}/recall.db")

class Memory
	include DataMapper::Resource

	property :memoryid,		Serial
	property :title,		String

	has n, :recollections
end

class Recollection
	include DataMapper::Resource

	property :recollectionid, Serial
	property :author,		String
	property :body,			Text
	property :created_at,	DateTime
	belongs_to :memory
end

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
	@memories = Memory.all
	haml :index
end

post '/' do
	memory = Memory.create(:title=>params[:title])
	recollection = memory.recollections.new
	recollection.attributes = {:author => params[:author], :body => params[:body], :created_at => Time.now}
	recollection.save

	redirect '/'
end

get '/memories/:memoryid/' do
	@memory = Memory.get(params[:memoryid])
	@originalauthor = @memory.recollections.first.author
	@recollection = @memory.recollections.last
	haml :memory
end

get '/memories/:memoryid/save' do
	@memory = Memory.get(params[:memoryid])
	haml :remember
end
post '/memories/:memoryid/save' do
	recollection = Memory.get(params[:memoryid]).recollections.new
	recollection.attributes = {:author => params[:author], :body => params[:body], :created_at => Time.now}
	recollection.save
	redirect '/'
end