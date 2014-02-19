module JserrorRails
  class Railtie < Rails::Engine
    initializer "sprockets.jserror_template", :after => "sprockets.environment", :group => :all do |app|
      next unless app.assets
      app.assets.register_engine(".debug", JserrorTemplate)
    end
  end
end
