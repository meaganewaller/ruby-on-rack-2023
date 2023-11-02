require "sqlite3"
require "thin"
require_relative "app"
require_relative "logger"
require_relative "lib/custom_logger_middleware"

Faye::WebSocket.load_adapter("thin")

thin = Rack::Handler.get("thin")

logger = Logger.new("custom.log")
db = SQLite3::Database.new("ruby_on_rack.db")

app = CustomLoggerMiddleware.new(MyApp.new(db), logger)

thin.run(app, Port: 9292)
