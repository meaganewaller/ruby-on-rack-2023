require "sqlite3"
require "thin"
require_relative "app"
require_relative "logger"
require_relative "lib/custom_logger_middleware"

Faye::WebSocket.load_adapter("thin")

app = CustomLoggerMiddleware.new(MyApp.new(SQLite3::Database.new("ruby_on_rack.db")), Logger.new("custom.log"))

run app
