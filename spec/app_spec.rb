require "rack/test"
require_relative "../app"

describe MyApp do
  include Rack::Test::Methods

  let(:app) { MyApp.new(SQLite3::Database.new(":memory:")) }

  describe "#initialize" do
    it "initializes a database connection" do
      expect(app.instance_variable_get(:@db)).to be_a(SQLite3::Database)
    end
  end

  describe "#create_posts_table" do
    it "creates the posts table" do
      expect { app.create_posts_table }.not_to raise_error
    end
  end

  describe "#insert_post" do
    it "inserts a post" do
      app.create_posts_table
      app.instance_variable_get(:@db).transaction do
        expect { app.insert_post("Hello, San Diego!", "This is a simple Rack application.") }.not_to raise_error
      end
    end
  end

  it 'responds with "Hello, San Diego!" for /hello' do
    get "/hello"
    expect(last_response).to be_ok
    expect(last_response.body).to eq("Hello, San Diego!")
  end

  it 'responds with "This is a simple Rack application." for /about' do
    get "/about"
    expect(last_response).to be_ok
    expect(last_response.body).to eq("This is a simple Rack application.")
  end

  it 'responds with "Not Found" for an unknown path' do
    get "/unknown"
    expect(last_response).to be_not_found
    expect(last_response.body).to eq("Not Found")
  end
end
