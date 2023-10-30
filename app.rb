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

  def insert_post(title, content)
    @db.execute('INSERT INTO posts (title, content) VALUES (?, ?)', [title, content])
  end

  def retrieve_posts
    @db.execute('SELECT * FROM posts')
  end

  def retrieve_post(id)
    @db.execute('SELECT * FROM posts WHERE id = ? LIMIT 1', id)[0]
  end

  def call(env)
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
    else
      render_not_found
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

    insert_post(title, content)

    [201, { 'Content-Type' => 'text/html' }, ['Post created']]
  end

  def view_posts
    posts = retrieve_posts

    if posts.empty?
      [200, { 'Content-Type' => 'text/html' }, ['No posts available']]
    else
      render_view('posts', posts: posts.reverse)
    end
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
  end

  def about_response
    render_view('about')
  end

  def format_posts(posts)
    formatted_posts = posts.map do |post|
      "<h2>#{post[1]}</h2><p>#{post[2]}</p>"
    end
    formatted_posts.join("\n")
  end
end
