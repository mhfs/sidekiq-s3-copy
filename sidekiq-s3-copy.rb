require 'sidekiq'
require 'fog'
require 'open-uri'
require 'pry'

class CopyAsset
  include Sidekiq::Worker

  def perform(url, path)
    file = open("#{url}#{path}")

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

connection = Fog::Storage.new(
  provider:              'AWS',
  aws_access_key_id:     ENV['ORIGIN_KEY'],
  aws_secret_access_key: ENV['ORIGIN_SECRET']
)

bucket = connection.directories.get(ENV['ORIGIN_BUCKET'])
url    = "https://#{ENV['ORIGIN_BUCKET']}.s3.amazonaws.com/"
files  = bucket.files

puts "Enqueueing files for asynchronous copy"

i = 0
files.each do |file|
  i += 1
  CopyAsset.perform_async(url, file.key)
end

puts "Enqueued #{i} jobs"
