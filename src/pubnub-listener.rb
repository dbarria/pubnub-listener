require 'pubnub'
require 'ougai'
require 'yaml'
require 'erb'

current_dir = File.dirname(File.expand_path(__FILE__))
template = ERB.new File.read "#{current_dir}/../config.yml"
config = YAML.load template.result binding
logger = Ougai::Logger.new("#{current_dir}/../log/#{config['log_name']}")

pb_logger = Logger.new("#{current_dir}/../log/pubnub.log")
logger.level = Logger::INFO
pubnub = Pubnub.new(
    publish_key: config['publish_key'],
    subscribe_key: config['subscribe_key'],
    auth_key: config['auth_key'],
    heartbeat:15,
    uuid: config['uuid'],
    ssl: config['ssl'],
    logger: pb_logger
)

pubnub.subscribe(
  channel_groups: config['channel_group']
)

callback = Pubnub::SubscribeCallback.new(
  message:  ->(envelope) {
      logger.info(envelope.result[:data][:message])
  }
)

pubnub.add_listener(callback: callback)
sleep
