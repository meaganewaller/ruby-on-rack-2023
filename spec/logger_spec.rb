require 'logger'
require 'tempfile'

describe Logger do
  let(:log_file) { Tempfile.new('test.log') }

  # Ensure that the log file is closed after each example
  after(:each) do
    log_file.close
    log_file.unlink # Remove the temporary log file
  end

  it 'writes log messages to the log file' do
    logger = Logger.new(log_file.path)
    message = 'This is a test message'

    logger.info(message)

    # Read the content of the log file and expect it to include the message
    log_content = File.read(log_file.path)
    expect(log_content).to include(message)
  end
end
