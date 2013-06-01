require 'sidekiq'
require 'sidekiq-failures'
require 'fog'
require 'open-uri'
require 'pry'

class CopyAsset
  include Sidekiq::Worker

  sidekiq_options :retry => 1

  def perform(path, url)
    file = open(URI.escape("#{url}"))

    bucket.files.create(
      key:    path,
      body:   file,
      public: true
    )
  end

  def fog
    @fog ||= Fog::Storage.new(
      provider:              'AWS',
      aws_access_key_id:     ENV['DEST_KEY'],
      aws_secret_access_key: ENV['DEST_SECRET']
    )
  end

  def bucket
    fog.directories.get(ENV['DEST_BUCKET'])
  end
end

if ENV['ENQUEUE']
  connection = Fog::Storage.new(
    provider:              'AWS',
    aws_access_key_id:     ENV['ORIGIN_KEY'],
    aws_secret_access_key: ENV['ORIGIN_SECRET']
  )

  bucket = connection.directories.get(ENV['ORIGIN_BUCKET'])
  files  = bucket.files

  puts "Enqueueing files for asynchronous copy"

  i = 0
  files.each do |file|
    i += 1
    url = bucket.files.new(:key => file.key).url(Time.now + 86400)
    CopyAsset.perform_async(file.key, url)
  end

  puts "Enqueued #{i} jobs"
end
