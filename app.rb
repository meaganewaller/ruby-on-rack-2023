class MyApp
  def call(env)
    request_path = env['PATH_INFO']

    if request_path == '/hello'
      hello_response
    elsif request_path == '/about'
      about_response
    else
      not_found_response
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
end
