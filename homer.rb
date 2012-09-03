subrequire 'rubygems'
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
	property :viewed,		Boolean

	belongs_to :memory
end

DataMapper.finalize
DataMapper.auto_upgrade!


get '/style.css' do
	sass :style
end

get '/' do
	@memories = Memory.all(Memory.recollections.viewed => nil)
	haml :index
end
post '/' do
	memory = Memory.create(:title=>params[:title])
	recollection = memory.recollections.new
	recollection.attributes = {:author => params[:author], :body => params[:body], :created_at => Time.now, :viewed => nil}
	recollection.save

	redirect '/'
end

get '/init' do
	Recollection.all.update(:viewed => true)
	memory = Memory.create(:title=>'The beginning of The Odyssey')
	recollection = memory.recollections.new
	recollection.attributes = {:author => "Homer", :body => "Tell me, O Muse, of that ingenious hero who travelled far and wide after he had sacked the famous town of Troy. Many cities did he visit, and many were the nations with whose manners and customs he was acquainted; moreover he suffered much by sea while trying to save his own life and bring his men safely home; but do what he might he could not save his men, for they perished through their own sheer folly in eating the cattle of the Sun-god Hyperion; so the god prevented them from ever reaching home. Tell me, too, about all these things, oh daughter of Jove, from whatsoever source you may know them.", :created_at => Time.now, :viewed => nil}
	recollection.save

	redirect '/'
end

get '/memories/:memoryid/' do
	@memory = Memory.get(params[:memoryid])
	@originalauthor = @memory.recollections.first.author
	@recollection = @memory.recollections.last
	@recollection.update(:viewed => true)
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

get '/history' do
	@memories = Memory.all
	haml :history
end