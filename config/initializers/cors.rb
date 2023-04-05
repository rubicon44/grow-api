# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins ENV["FRONTEND_ORIGIN"]
    # origins '*'
    # resource '*',
    #   headers: :any,
    #   methods: [:get, :post, :put, :patch, :delete, :options, :head]
    origins 'https://grow-gilt.vercel.app'
    resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head], expose: ['Access-Control-Allow-Origin'], credentials: true
  end
end
