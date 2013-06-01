$LOAD_PATH.unshift File.dirname(__FILE__)

require 'sidekiq/web'
require 'sidekiq-failures'

run Sidekiq::Web
