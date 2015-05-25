RSpec.shared_examples_for 'a Key' do
  [:key, :parent, :load!, :save!, :delete!, :collection?,
   :stored?, :shortname, :classname, :<=>].each do |m|
    it { is_expected.to respond_to(m) }
  end

  it { is_expected.to be_a(Comparable) }

  it 'has the correct key name' do
    expect(subject.key).to be(keyname)
  end

  [:key, :classname].each do |m|
    it "shows the #{m} in #shortname" do
      # restrict match only if we actually have a non-nil string
      str = subject.public_send(m)
      re_str = str ? Regexp.escape(str) : '.*'
      expect(subject.shortname).to match(Regexp.new("\\b#{re_str}\\b"))
    end
  end
end

RSpec.shared_examples_for 'non-root' do
  it 'has a non root type' do
    expect(subject.type).not_to be(:root)
  end

  it 'has a parent different than itself' do
    expect(subject.parent).not_to be(subject)
  end
end

RSpec.shared_examples_for 'root' do
  it 'has a root type' do
    expect(subject.type).to be(:root)
  end

  it 'has itself as parent' do
    expect(subject.parent).to be(subject)
  end
end

RSpec.shared_examples_for 'unparented' do
  it 'does not have a valid parent' do
    expect(subject.parent).to be_nil
  end
end

RSpec.shared_examples_for 'parented' do
  let(:parent) { subject.parent }

  it 'has a non-nil parent' do
    expect(parent).not_to be_nil
  end

  it 'has a parent that is a collection' do
    expect(parent).to be_collection
  end
end

RSpec.shared_examples_for 'stored' do
  it_behaves_like 'parented'

  it 'exists in the storage when asking its parent' do
    expect(subject.parent.include? subject).to be_truthy
  end

  it 'exists in the storage when asking itself' do
    expect(subject).to be_stored
  end
end

RSpec.shared_examples_for 'a stored key' do
  let(:parent) { subject.parent }

  it_behaves_like 'stored'

  it 'can fetch itself through parent#get' do
    expect { parent.get subject }.not_to raise_error
  end

  it 'fetches a non-nil value through parent#get' do
    expect(parent.get subject).not_to be_nil
  end

  it 'can fetch itself through self#load!' do
    expect { subject.load! }.not_to raise_error
  end

  it 'fetches a non-nil value through self#load!' do
    expect(subject.load!).not_to be_nil
  end

  it 'fetches the same key from #load! than from parent#get' do
    expect(parent.get subject).to be(subject.load!)
  end
end

RSpec.shared_examples_for 'an unparented key' do
  it_behaves_like 'unparented'

  it 'fails when trying to write to storage' do
    expect { subject.save! }.to raise_error
  end

  it 'fails when trying to read from storage' do
    expect { subject.load! }.to raise_error
  end

  it 'succeeds when trying to delete from storage' do
    expect { subject.delete! }.to raise_error
  end
end

RSpec.shared_examples_for 'a parented key' do
  it_behaves_like 'parented'

  it 'succeeds when trying to write to storage' do
    expect { subject.save! }.not_to raise_error
  end

  it 'succeeds when trying to read from storage' do
    expect { subject.load! }.not_to raise_error
  end

  it 'succeeds when trying to delete from storage' do
    expect { subject.delete! }.not_to raise_error
  end
end
