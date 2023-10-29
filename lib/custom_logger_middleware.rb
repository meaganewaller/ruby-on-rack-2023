require_relative '../logger'

class CustomLoggerMiddleware
  def initialize(app, logger)
    @app = app
    @logger = logger
  end

  def call(env)
    @logger.info("Received request: #{env['REQUEST_METHOD']} #{env['PATH_INFO']}")

    status, headers, response = @app.call(env)

    @logger.info("Responded with: #{status} #{headers['Content-Type']}")

    [status, headers, response]
  end
end
