# typed: false

namespace :storage do
  desc "Ensure the SeaweedFS S3 bucket configured for Active Storage exists (idempotent)."
  task ensure_bucket: :environment do
    require "aws-sdk-s3"
    require "erb"
    require "yaml"

    raw = ERB.new(File.read(Rails.root.join("config/storage.yml"))).result
    services = YAML.safe_load(raw, aliases: true, permitted_classes: [ Symbol ])
    config = services.fetch("seaweed")

    client = Aws::S3::Client.new(
      endpoint: config["endpoint"],
      access_key_id: config["access_key_id"],
      secret_access_key: config["secret_access_key"],
      region: config["region"],
      force_path_style: true
    )

    bucket = config["bucket"]
    begin
      client.create_bucket(bucket: bucket)
      puts "Created bucket #{bucket} at #{config['endpoint']}"
    rescue Aws::S3::Errors::BucketAlreadyOwnedByYou,
           Aws::S3::Errors::BucketAlreadyExists
      puts "Bucket #{bucket} already exists at #{config['endpoint']}"
    end
  end
end
