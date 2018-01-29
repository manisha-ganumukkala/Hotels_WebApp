# Load the Rails application.
require_relative 'application'

# Load AWS Settings
AWS_SETTINGS = YAML.load_file("#{Rails.root}/config/aws_apigateway.yml")

# Initialize the Rails application.
Rails.application.initialize!

