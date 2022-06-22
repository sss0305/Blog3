#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

#инициализация глобальной переменной базы данных
def init_db
 @db = SQLite3::Database.new 'blog.db'
 @db.results_as_hash = true 
end

# вызывается каждый раз при перезагрузке любой страницы
before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE if not exists "posts" (
	"id"	INTEGER PRIMARY KEY AUTOINCREMENT,
	"created_date"	DATE,
	"content"	TEXT 
);'
end


get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/new' do
  erb :new
end

post '/new' do
    @content = params[:content]
    if @content.length < 15
    	@error = "Type text more than 15 letters. #{15-@content.length} letters left."
    	return erb :new
    end

    erb "You typed #{@content}"

end