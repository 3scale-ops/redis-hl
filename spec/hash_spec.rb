module RedisHL
  RSpec.describe Hash do
    let(:keyname) { 'my_hash' }
    let(:redis) { FakeRedis::Redis.new }
    let(:client) { Client.new(redis, config: nil) }
    subject { Hash.new keyname, parent: nil }

    it_behaves_like 'a Key'
    it_behaves_like 'a non-root collection'

    context 'when parented' do
      context 'to root' do
        before do
          subject.reparent(client.root)
        end

        it_behaves_like 'parented'

        context 'when saved to storage' do
          before do
            subject.naked_set 'dummy_keyvalue', 'dummy_value'
          end

          after do
            subject.naked_del 'dummy_keyvalue'
          end

          it_behaves_like 'stored'
        end
      end
    end
  end
end
