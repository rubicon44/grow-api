# frozen_string_literal: true

require 'aws-sdk-s3'

class S3Uploader
  def self.upload_avatar_url_to_s3(avatar_file)
    bucket_name = ENV['AWS_S3_BUCKET_NAME']
    region = ENV['AWS_REGION']
    access_key_id = ENV['AWS_ACCESS_KEY_ID']
    secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']

    s3 = Aws::S3::Resource.new(region: region, access_key_id: access_key_id, secret_access_key: secret_access_key)

    bucket = s3.bucket(bucket_name)
    obj = bucket.object(avatar_file.original_filename)
    obj.put(body: avatar_file) # ファイルのバイナリデータをアップロード

    # 公開可能なURLを取得
    obj.public_url
  end
end
