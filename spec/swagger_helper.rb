require 'rails_helper'
require 'api/helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's confiugred to server Swagger from the same folder
  config.swagger_root = Rails.root.to_s + '/swagger'

  config.swagger_dry_run = false

  config.after do |example|
    if respond_to?(:response) && response
      if ENV['debug']
        p '-'*100, 'response ->', JSON.parse(response.body, symbolize_names: true), '-'*100
      end
      example.metadata[:response][:examples] = {
       'application/json' => JSON.parse(response.body, symbolize_names: true)
      }
    end
  end

  config.before(:each) do
    if rswag_properties[:current_organization]
      host! "#{rswag_properties[:current_organization].subdomain}.example.com"
    end
  end

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:to_swagger' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.json' => {
      swagger: '2.0',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {}
    }
  }
end
