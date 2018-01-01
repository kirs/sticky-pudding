require 'bundler/setup'

require "sinatra"
require "sinatra/cookies"
require "pg"
require "sequel"

POSTGRES_PORT = Integer(ENV["POSTGRES_PORT"] || abort("need POSTGRES_PORT"))

DB = Sequel.connect("postgres://localhost:#{POSTGRES_PORT}/sticky-pudding",
  servers: {
    replica: { port: POSTGRES_PORT + 1 }
  }
)

class Kitten < Sequel::Model
end

class App < Sinatra::Base
  helpers Sinatra::Cookies

  STICKY_TIMEOUT = 10 # in seconds

  set :server, %w[puma]
  set :show_exceptions, true

  get '/' do
    erb :new
  end

  post "/kittens" do
    DB.transaction do
      record = Kitten.create(
        name: params["kitten"]["name"],
      )

      response.set_cookie(:sticky_writer, value: "1", expires: Time.now + STICKY_TIMEOUT)
      redirect "/kittens/#{record.id}"
    end
  end

  get "/kittens/:id" do |id|
    if cookies[:sticky_writer]
      @target_db_server = :default
    else
      @target_db_server = :replica
    end

    $stdout.puts "Reading record #{id} from server '#{@target_db_server}'"

    @kitten = Kitten.server(@target_db_server).first(id: id)
    erb :show
  end
end

App.run!
