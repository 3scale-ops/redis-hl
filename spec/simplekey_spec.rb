module RedisHL
  RSpec.describe SimpleKey do
    let(:keyname) { 'simple' }
    let(:redis) { FakeRedis::Redis.new }
    let(:client) { Client.new(redis, config: nil) }
    subject { SimpleKey.new keyname, parent: nil }

    it_behaves_like 'a Key'
    it_behaves_like 'a SimpleKey'

    it { is_expected.not_to be_collection }

    context 'when unparented' do
      it_behaves_like 'an unparented key'
    end

    context 'when parented' do
      [:set, :list].each do |type|
        context "to #{type}" do
          let(:collection) { client.root.create "a_dummy_#{type}", type }

          before do
            collection.naked_set('dummy_simplekey')
            subject.reparent(collection)
          end

          after do
            collection.naked_del('dummy_simplekey')
          end

          it_behaves_like 'a parented key'

          context 'when saved to storage' do
            before do
              subject.save!
            end

            after do
              subject.delete!
            end

            it_behaves_like 'a stored key'
          end
        end
      end
    end
  end
end
