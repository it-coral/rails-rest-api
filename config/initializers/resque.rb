if ENV["REDISCLOUD_URL"]
  Resque.redis = Redis.new(url: ENV["REDISCLOUD_URL"])
else
  RESQUE_CONFIG = Config.get('resque')

  Resque.redis = Redis.new(
    host: RESQUE_CONFIG[:host],
    port: RESQUE_CONFIG[:port],
    password: RESQUE_CONFIG[:password]
  )
end
