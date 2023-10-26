class MyApp
  def call(_env)
    [200, { 'Content-Type' => 'text/html' }, ['Hello, San Diego!']]
  end
end
