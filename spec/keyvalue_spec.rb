module RedisHL
  RSpec.describe KeyValue do
    let(:keyname) { 'kv' }
    let(:redis) { FakeRedis::Redis.new }
    let(:client) { Client.new(redis, config: nil) }
    let(:value) { 1 }
    subject { KeyValue.new keyname, parent: nil }

    it_behaves_like 'a Key'
    it_behaves_like 'a KeyValue'

    it { is_expected.not_to be_collection }

    context 'when unparented' do
      it_behaves_like 'an unparented key'
    end

    context 'when parented' do
      before do
        subject.value = value
      end

      context 'to root' do
        before do
          subject.reparent(client.root)
        end

        it_behaves_like 'a parented key'

        context 'when saved to storage' do
          before do
            subject.value = 1
            subject.save!
          end

          after do
            subject.delete!
          end

          it_behaves_like 'a stored KeyValue'

          it 'fetches the correct value' do
            expect(subject.load!.to_i).to be(value)
          end
        end
      end

      context 'to hash' do
        let(:hash) { client.root.create 'a_dummy_hash', :hash }

        before do
          hash.naked_set 'dummyfield', 'dummyvalue'
          subject.reparent hash
        end

        after do
          hash.naked_del keyname
          hash.naked_del 'dummyfield'
        end

        it_behaves_like 'a parented key'

        context 'when saved to storage' do
          before do
            subject.value = 1
            subject.save!
          end

          after do
            subject.delete!
          end

          it_behaves_like 'a stored KeyValue'

          it 'fetches the correct value' do
            expect(subject.load!.to_i).to be(value)
          end
        end
      end
    end
  end
end
