require "rack/test"
require_relative "../app"

describe MyApp do
  include Rack::Test::Methods

  def app
    MyApp.new
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
