require 'spec_helper'

describe GoogleStorage::Client do

  let(:client) {
    GoogleStorage::TestClient.new :config_yml => GS_YML_LOCATION
  }

  context '#get_webcfg' do
    context 'bucket exists with no webcfg' do
      let(:bucket_name) { 
        BucketLibrary.use(
          self.class.description, 
          :method => :create_bucket
        )['uuid']
      }

      subject { client.get_webcfg bucket_name }

      it 'does not return a webcfg' do
        subject[:success].should be_true
        subject[:bucket_name].should == bucket_name
        subject['WebsiteConfiguration'].should be_nil
      end
    end

    context 'bucket exists with a webcfg' do 
      let(:bucket_name) { 
        BucketLibrary.use(
          self.class.description, 
          :method => :create_bucket,
          :method_opt => {:x_goog_acl => 'public-read'}
        )['uuid']
      }

      subject { client.get_webcfg bucket_name }

      before(:each) {
        client.set_webcfg bucket_name, {
          'MainPageSuffix'  =>  'index.html',
          'NotFoundPage'    =>  '404.html'
        }
      }

      it 'returns the existing webcfg' do
        subject[:success].should be_true
        subject[:bucket_name].should == bucket_name
        subject['WebsiteConfiguration'].should == {
          'MainPageSuffix'  =>  'index.html', 
          'NotFoundPage'    =>  '404.html'
        } 
      end
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

        it 'acknowledges operation success' do
          subject[:success].should be_true
          subject[:bucket_name].should == bucket_name
          subject[:message].should == 'Website Configuration successful'
        end
      end

      context 'client ensures no config exists' do
        subject { client.set_webcfg bucket_name, nil}

        it 'acknowledges operation success' do
          subject[:success].should be_true
          subject[:bucket_name].should == bucket_name
          subject[:message].should == 'Website Configuration successful'
        end
      end
    end
  end

end
