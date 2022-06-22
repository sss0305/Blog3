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

	@db.execute 'CREATE TABLE if not exists "comments" (
	"id"	INTEGER PRIMARY KEY AUTOINCREMENT,
	"created_date"	DATE,
	"content"	TEXT,
	"post_id" INTEGER
);'
end


get '/' do
	@results = @db.execute 'select * from posts order by id desc'
	@db.close

	erb :index
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

    @db.execute 'insert into posts (created_date, content) values (datetime(),?)', [@content]

    redirect to '/'
end

#вывод инфо о посте
get '/details/:post_id' do
	#получаем переменную из url
	post_id = params[:post_id]
	
	#получаем список постов (только один)
	results = @db.execute 'select * from posts where id = ?', [post_id]
	
	#выбираем один пост в переменную row
	@row = results[0]

	@comments = @db.execute 'select * from comments where post_id = ? order by id desc', [post_id]
	@db.close

	erb :details
end


#обработчик постзапроса, браузер отправляет данные, мы принимаем

post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]

	#сохранение данных в бд
	@db.execute 'insert into comments (created_date, content, post_id) values (datetime(),?,?)', [content, post_id]

	
	redirect to ('/details/' + post_id)

	#erb "you typed comment #{content} for post ID#{post_id}"


end