module RedisHL
  RSpec.describe Root do
    let(:keyname) { nil }
    let(:redis) { FakeRedis::Redis.new }
    let(:client) { Client.new(redis, config: nil) }
    subject { client.root }

    it_behaves_like 'a Key'
    it_behaves_like 'a parented key'
    it_behaves_like 'a collection'
  end
end
