require 'rubygems'
require 'sinatra'
require 'haml'
require 'dm-core'
require 'dm-migrations'

set :haml, :format => :html5


DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/recall.db")

class Memory
	include DataMapper::Resource

	property :id,			Serial
	property :author,		String
	property :created_at,	DateTime
	property :body,			Text
end


DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do 
	@memory = Memory.first
	haml :index
end

get '/init' do
	memory = Memory.create(
		:author		=> 'Homer',
		:created_at => Time.now,
		:body		=> "Tell me, O Muse, of that ingenious hero who travelled far and wide after he had sacked the famous town of Troy. Many cities did he visit, and many were the nations with whose manners and customs he was acquainted; moreover he suffered much by sea while trying to save his own life and bring his men safely home; but do what he might he could not save his men, for they perished through their own sheer folly in eating the cattle of the Sun-god Hyperion; so the god prevented them from ever reaching home. Tell me, too, about all these things, oh daughter of Jove, from whatsoever source you may know them."
	)
	redirect '/'
end