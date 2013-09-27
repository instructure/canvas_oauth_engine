module CanvasOauth
  module RedisConfig
    def self.setup!
      config_file = CanvasOauth.app_root.join('config/redis.yml')

      redis_uri = if File.exists?(config_file)
                    Rails.logger.info "Initializing Redis from #{config_file}"
                    YAML::load(File.open(config_file))[Rails.env]['uri']
                  elsif ENV['REDISTOGO_URL'].present?
                    Rails.logger.info "Initializing Redis using REDISTOGO_URL"
                    ENV['REDISTOGO_URL']
                  else
                    default_uri = 'redis://localhost:6379'
                    Rails.logger.info "Initializing Redis using default of #{default_uri}"
                    default_uri
                  end

      uri = URI.parse(redis_uri)
      $REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      Resque.redis = $REDIS if defined?(Resque)
      Redis.current = $REDIS
    end
  end
end
