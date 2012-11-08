require 'spec_helper'

describe GoogleStorage::Config do
  subject { GoogleStorage::Config.new }

  context '#initialize' do
    it { subject.log_stream.should be $stdout }
    it { subject.log_level.should be GoogleStorage::Logger::FATAL }
  end

  context '#from_yaml' do
    context 'with invalid config' do
      it { expect { subject.from_yaml }.to raise_error ArgumentError }
      it { expect { subject.from_yaml('.') }.to raise_error SystemCallError }
    end
    context 'with valid yaml config' do
      subject { GoogleStorage::Config.new.from_yaml $google_storage_yml_path }
      it { expect { subject }.to_not raise_error }
      it { subject.class.should be GoogleStorage::Config }

      # it { subject.project_id.should have(8).characters }
      # it { subject.client_id.should have(39).characters }
      # it { subject.client_secret.should have(24).characters }
      # it { subject.refresh_token.should have(45).characters }
    end
  end

  context '#access_token' do
    subject do
      GoogleStorage::Config.new.from_yaml(
        $google_storage_yml_path
      ).after_refresh_access_token do |response|
        $silence_access_token.call response
      end
    end

    context 'recorded tests' do
      it { subject.instance_variable_get(:@access_token).should be_nil }
      it { subject.instance_variable_get(:@access_token_expiry).should be_nil }
      it { subject.access_token_expired?.should be_true }

      # it { subject.access_token.should == '____SILENCED_access_token____' }
    end
    # context 'live tests', vcr: {record: :all} do
    #   it { subject.access_token.should have(60).characters }
    #   it { subject.refresh_access_token; subject.access_token_expired?.should be_false }
    # end
  end
end
