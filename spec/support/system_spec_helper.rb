RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include ActiveJob::TestHelper, type: :system
end
