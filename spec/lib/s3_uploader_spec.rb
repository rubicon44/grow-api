# frozen_string_literal: true

require 'rails_helper'

RSpec.describe S3Uploader do
  describe 'S3Uploader.upload_avatar_url_to_s3' do
    context 'when uploading the avatar file to AWS S3' do
      it 'returns the avatar URL' do
        s3_instance = instance_double(Aws::S3::Object)
        allow(s3_instance).to receive(:public_url).and_return('https://s3-bucket-for-user-avatar.s3.amazonaws.com/avatar_1.png')
        allow(s3_instance).to receive(:put) # putメソッドをスタブ化して何もしないように設定

        s3_resource_instance = instance_double(Aws::S3::Resource, bucket: double(object: s3_instance))
        allow(Aws::S3::Resource).to receive(:new).and_return(s3_resource_instance)

        avatar_file = fixture_file_upload('avatar_1.png', 'image/png')
        avatar_url = S3Uploader.upload_avatar_url_to_s3(avatar_file)

        expect(avatar_url).to eq('https://s3-bucket-for-user-avatar.s3.amazonaws.com/avatar_1.png')
      end
    end

    context 'when the avatar file upload fails' do
      it 'returns an error message' do
        allow_any_instance_of(Aws::S3::Object).to receive(:put).and_raise(StandardError)

        avatar_file = fixture_file_upload('avatar_1.png', 'image/png')
        expect { S3Uploader.upload_avatar_url_to_s3(avatar_file) }.to raise_error(StandardError)
      end
    end
  end
end
