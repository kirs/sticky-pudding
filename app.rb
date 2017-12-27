require 'bundler/setup'

require "sinatra"
require "sinatra/cookies"
require "pg"
require "sequel"

NUM_REPLICAS  = Integer(ENV["NUM_REPLICAS"]  || abort("need NUM_REPLICAS"))
POSTGRES_PORT = Integer(ENV["POSTGRES_PORT"] || abort("need POSTGRES_PORT"))

DB = Sequel.connect("postgres://localhost:#{POSTGRES_PORT}/sticky-writer-",
  servers: Hash[NUM_REPLICAS.times.map { |i|
    [:"replica#{i}", { port: POSTGRES_PORT + 1 + i }]
  }]
)

class Product < Sequel::Model
end

class App < Sinatra::Base
  helpers Sinatra::Cookies

  set :server, %w[puma]
  set :show_exceptions, true

  get '/' do
    erb :new
  end

  post "/products" do
    DB.transaction do
      record = Product.create(
        title: params["product"]["title"],
        price: params["product"]["price"]
      )

      response.set_cookie(:sticky_writer, value: "1", expires: Time.now + 10)
      redirect "/products/#{record.id}"
    end
  end

  get "/products/:id" do |id|
    if cookies[:sticky_writer]
      @target_db_server = :default
    else
      replica_names = DB.servers[1..-1]
      @target_db_server = replica_names.sample
    end

    $stdout.puts "Reading record #{id} from server '#{@target_db_server}'"

    @product = Product.server(@target_db_server).first(id: id)
    erb :show
  end
end

App.run!
