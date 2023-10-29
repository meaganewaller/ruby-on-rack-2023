require_relative 'app'
require_relative 'logger'
require_relative 'lib/custom_logger_middleware'

logger = Logger.new('custom.log')

app = CustomLoggerMiddleware.new(MyApp.new, logger)

run app
