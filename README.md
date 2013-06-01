# Sidekiq S3 Bucket Copy

Copy all files from one s3 bucket to another.

## Running

Clone the repo:

```
git clone git@github.com:mhfs/sidekiq-s3-copy.git
```

Bundle the gems:

```
bundle
```

Run sidekiq-web:

```
bundle exec rackup
```

Access `http://localhost:9292/`

It's time to consume them:

```
bundle exec sidekiq -r ./sidekiq-s3-copy.rb
```
