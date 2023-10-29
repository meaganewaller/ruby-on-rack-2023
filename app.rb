require 'faye/websocket'
require 'sqlite3'
require 'slim'

class MyApp
  def initialize(db)
    @db = db
  end

  def create_posts_table
    @db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY,
    title TEXT,
    content TEXT
    );
    SQL
  end

  def create_tils_table
    @db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS tils (
    id INTEGER PRIMARY KEY,
    content TEXT
    );
    SQL
  end

  def insert_post(title, content)
    @db.execute('INSERT INTO posts (title, content) VALUES (?, ?)', [title, content])
  end

  def insert_til(content)
    @db.execute('INSERT INTO tils (content) VALUES (?)', content)

    til_id = @db.last_insert_row_id

    retrieve_til(til_id)
  end

  def retrieve_posts
    @db.execute('SELECT * FROM posts')
  end

  def retrieve_tils
    @db.execute('SELECT * FROM tils')
  end

  def retrieve_til(id)
    @db.execute('SELECT * FROM tils WHERE id = ? LIMIT 1', id)[0]
  end

  def retrieve_post(id)
    @db.execute('SELECT * FROM posts WHERE id = ? LIMIT 1', id)[0]
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env)
      @clients ||= []
      @clients << ws

      ws.on :message do |event|
        ws.send(event.data)
      end

      ws.on :close do |_event|
        @clients.delete(ws)
      end

      ws.rack_response
    else
      request_path = env['PATH_INFO']

      case request_path
      when '/'
        index_response
      when '/about'
        about_response
      when '/create_post'
        if env['REQUEST_METHOD'] == 'POST'
          create_post(env)
        else
          [405, { 'Content-Type' => 'text/html' }, ['Method Not Allowed']]
        end
      when '/posts'
        if env['REQUEST_METHOD'] == 'GET'
          view_posts
        else
          [405, { 'Content-Type' => 'text/html' }, ['Method Not Allowed']]
        end
      when %r{/posts/(\d+)} # New route for dynamic post retrieval
        post_id = Regexp.last_match(1).to_i
        show_post(post_id)
      when '/til'
        if env['REQUEST_METHOD'] == 'GET'
          view_tils
        elsif env['REQUEST_METHOD'] == 'POST'
          create_til(env)
        else
          [405, { 'Content-Type' => 'text/html' }, ['Method Not Allowed']]
        end
      else
        render_not_found
      end
    end
  end

  private

  def render_view(view_name, locals = {})
    template = File.read("views/#{view_name}.slim")
    rendered = Slim::Template.new { template }.render(self, locals)
    [200, { 'Content-Type' => 'text/html' }, [rendered]]
  end

  def render_not_found
    template = File.read('views/not_found.slim')
    rendered = Slim::Template.new { template }.render(self)
    [404, { 'Content-Type' => 'text/html' }, [rendered]]
  end

  def create_post(env)
    request = Rack::Request.new(env)
    title = request.params['title']
    content = request.params['content']

    post = insert_post(title, content)
    insert_post(title, content)

    [201, { 'Content-Type' => 'text/html' }, ['Post created']]
  end

  def create_til(env)
    request = Rack::Request.new(env)
    content = request.params['content']

    insert_til(content)
    send_til_to_websockets(content)

    [201, { 'Content-Type' => 'text/html' }, ['TIL created']]
  end

  def send_til_to_websockets(content)
    return unless @clients

    @clients.each do |client|
      client.send(content)
    end
  end

  def view_posts
    posts = retrieve_posts

    if posts.empty?
      [200, { 'Content-Type' => 'text/html' }, ['No posts available']]
    else
      render_view('posts', posts: posts.reverse)
    end
  end

  def view_tils
    tils = retrieve_tils || []

    render_view('til', tils:)
  end

  def show_post(id)
    post = retrieve_post(id)

    if post
      render_view('post', post:)
    else
      render_not_found
    end
  end

  def index_response
    render_view('index')
    [200, { 'Content-Type' => 'texthtml' }, [format_posts(posts)]]
  end

  def hello_response
    [200, { 'Content-Type' => 'text/html' }, ['Hello, San Diego!']]
  end

  def about_response
    render_view('about')
  end

  private

  def format_posts(posts)
    formatted_posts = posts.map do |post|
      "<h2>#{post[1]}</h2><p>#{post[2]}</p>"
    end
    formatted_posts.join("\n")
  end
end
