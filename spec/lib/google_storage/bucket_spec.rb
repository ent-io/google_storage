require 'spec_helper'

##
# Prep for recording new episodes:
#
#  1. Initialize client.
#
#     GoogleStorage.configure {|c| c.from_yaml 'spec/support/google_storage.yml'}
#     client = GoogleStorage::Client.new
#
#  2. Recreate expected test suite state remotely.
#
#     client.create_bucket '7829f2c0-0476-0130-7985-0023dfa5d78c'
#
#     client.create_bucket '9c0a6d00-0478-0130-7986-0023dfa5d78c', :x_goog_acl => 'public-read'
#     client.set_webcfg '9c0a6d00-0478-0130-7986-0023dfa5d78c', {'MainPageSuffix' => 'index.html', 'NotFoundPage' => '404.html'}
#
#     client.create_bucket '7baa01c0-04f5-0130-7987-0023dfa5d78c', :x_goog_acl => 'public-read'
#
# Bucket names are UUIDs (or GUIDs). Generate new ones with
#
#     require 'uuid'
#     UUID.new.generate
#
##

describe GoogleStorage::Client do

  let(:client) { GoogleStorage.client }

  context '#get_webcfg' do

    context 'bucket exists with no webcfg' do
      let(:bucket_name) { 
        BucketLibrary.use(
          self.class.description, 
          :method => :create_bucket
        )['uuid']
      }

      subject { client.get_webcfg bucket_name }

      it { subject[:success].should be_true }
      it { subject[:bucket_name].should == bucket_name }
      it { subject['WebsiteConfiguration'].should be_nil }
    end

    context 'bucket exists with a webcfg' do 
      let(:bucket_name) { 
        BucketLibrary.use(
          self.class.description, 
          :method => :create_bucket,
          :method_opt => {:x_goog_acl => 'public-read'}
        )['uuid']
      }

      before(:each) do
        client.set_webcfg bucket_name, {
          'MainPageSuffix'  =>  'index.html',
          'NotFoundPage'    =>  '404.html'
        }
      end

      subject { client.get_webcfg bucket_name }

      it { subject[:success].should be_true }
      it { subject[:bucket_name].should == bucket_name }
      it { subject['WebsiteConfiguration'].should ==
        {
          'MainPageSuffix'  =>  'index.html', 
          'NotFoundPage'    =>  '404.html'
        } 
      }
    end

  end

  context '#set_webcfg' do

    context 'bucket exists with unkown webcfg' do
      let(:bucket_name) { 
        BucketLibrary.use(
          self.class.description, 
          :method => :create_bucket,
          :method_opt => {:x_goog_acl => 'public-read'}
        )['uuid']
      }

      context 'client ensures correct config exists' do
        subject { client.set_webcfg bucket_name, {
            'MainPageSuffix'  =>  'index.html',
            'NotFoundPage'    =>  '404.html'
          }
        }

        it { subject[:success].should be_true }
        it { subject[:bucket_name].should == bucket_name }
        it { subject[:message].should == 'Website Configuration successful' }
      end

      context 'client ensures no config exists' do
        subject { client.set_webcfg bucket_name, nil}

        it { subject[:success].should be_true }
        it { subject[:bucket_name].should == bucket_name }
        it { subject[:message].should == 'Website Configuration successful' }
      end
    end

  end

end
