require 'sqlite3'

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

  def call(env)
    request_path = env['PATH_INFO']

    case request_path
    when '/hello'
      hello_response
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
    else
      not_found_response
    end
  end

  private

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
      [200, { 'Content-Type' => 'text/html' }, [format_posts(posts)]]
    end
  end

  def hello_response
    [200, { 'Content-Type' => 'text/html' }, ['Hello, San Diego!']]
  end

  def about_response
    [200, { 'Content-Type' => 'text/html' }, ['This is a simple Rack application.']]
  end

  def not_found_response
    [404, { 'Content-Type' => 'text/html' }, ['Not Found']]
  end


  def format_posts(posts)
    formatted_posts = posts.map do |post|
      "<h2>#{post[1]}</h2><p>#{post[2]}</p>"
    end
    formatted_posts.join("\n")
  end
end
