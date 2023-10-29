require 'rack/test'
require_relative '../../lib/custom_logger_middleware'
require_relative '../../app'
require_relative '../../logger'

describe CustomLoggerMiddleware do
  include Rack::Test::Methods

  let(:logger) { Logger.new('test.log') }

  def app
    CustomLoggerMiddleware.new(MyApp.new(SQLite3::Database.new(':memory:')), logger)
  end

  it 'logs incoming requests and outgoing responses' do
    get '/hello'

    log_contents = File.read('test.log')

    expect(log_contents).to include('Received request:')
    expect(log_contents).to include('Responded with:')
  end
end
