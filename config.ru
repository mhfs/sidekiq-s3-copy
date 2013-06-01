$LOAD_PATH.unshift File.dirname(__FILE__)

require 'sidekiq/web'

run Sidekiq::Web
