require 'rack/test'
require_relative '../app'

describe MyApp do
  include Rack::Test::Methods

  let(:app) { MyApp.new(SQLite3::Database.new(':memory:')) }

  describe '#initialize' do
    it 'initializes a database connection' do
      expect(app.instance_variable_get(:@db)).to be_a(SQLite3::Database)
    end
  end

  describe '#create_posts_table' do
    it 'creates the posts table' do
      expect { app.create_posts_table }.not_to raise_error
    end
  end

  describe '#insert_post' do
    before { app.create_posts_table }

    it 'does not raise an error' do
      expect { app.retrieve_posts }.not_to raise_error
    end

    it 'inserts a post' do
      app.instance_variable_get(:@db).transaction do
        expect { app.insert_post('Hello, San Diego!', 'This is a simple Rack application.') }.not_to raise_error
      end
    end
  end

  describe '#retrieve_posts' do
    before do
      app.create_posts_table
      app.insert_post('Hello, San Diego!', 'This is a simple Rack application')
      app.insert_post('Another Post!', 'This is another post')
    end

    it 'does not raise an error' do
      expect { app.retrieve_posts }.not_to raise_error
    end

    it 'returns all posts' do
      expect(app.retrieve_posts).to eq(
        [
          [1, 'Hello, San Diego!', 'This is a simple Rack application'],
          [2, 'Another Post!', 'This is another post']
        ]
      )
    end
  end

  describe '#create_post' do
    it 'inserts a post' do
      app.create_posts_table

      post_data = {
        'title' => 'New Post Title',
        'content' => 'This is the content of a new post.'
      }

      post '/create_post', post_data

      expect(last_response).to be_created
      expect(last_response.body).to include('Post created')
    end

    it 'returns Method Not Allowed for non-POST requests' do
      get '/create_post'
      expect(last_response).to be_method_not_allowed
      expect(last_response.body).to include('Method Not Allowed')
    end
  end

  describe '#view_posts' do
    it 'displays available posts' do
      app.create_posts_table
      app.insert_post('Test Post 1', 'This is the first test post.')
      app.insert_post('Test Post 2', 'This is the second test post.')

      get '/posts'

      expect(last_response).to be_ok
      expect(last_response.body).to include('Test Post 1')
      expect(last_response.body).to include('Test Post 2')
    end

    it 'displays a message for no posts available' do
      app.create_posts_table

      get '/posts'

      expect(last_response).to be_ok
      expect(last_response.body).to include('No posts available')
    end

    it 'returns Method Not Allowed for non-GET requests' do
      post '/posts'
      expect(last_response).to be_method_not_allowed
      expect(last_response.body).to include('Method Not Allowed')
    end
  end

  it 'responds with "Hello, San Diego!" for /hello' do
    get '/hello'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Hello, San Diego!')
  end

  it 'responds with "This is a simple Rack application." for /about' do
    get '/about'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('This is a simple Rack application.')
  end

  it 'responds with "Not Found" for an unknown path' do
    get '/unknown'
    expect(last_response).to be_not_found
    expect(last_response.body).to eq('Not Found')
  end
end
