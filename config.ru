require "sqlite3"
require_relative "app"
require_relative "logger"
require_relative "lib/custom_logger_middleware"

logger = Logger.new("custom.log")
db = SQLite3::Database.new("ruby_on_rack.db")

app = CustomLoggerMiddleware.new(MyApp.new(db), logger)

run app
