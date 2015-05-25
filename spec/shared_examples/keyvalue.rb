RSpec.shared_examples_for 'a KeyValue' do
  it 'has type of :string' do
    expect(subject.type).to be(:string)
  end

  [:value, :value=].each do |m|
    it { is_expected.to respond_to(m) }
  end

  it 'shows the value in #shortname' do
    subject.value = (rand * 1000).to_i
    expect(subject.shortname).to match(Regexp.new("\\b#{Regexp.escape(subject.value.to_s)}\\b"))
  end

  it 'changes its value when assigning to it through #value=' do
    oldvalue = subject.value
    newvalue = "new#{oldvalue}"
    expect { subject.value = newvalue }.to change { subject.value }.from(oldvalue).to(newvalue)
  end
end

RSpec.shared_examples_for 'a stored KeyValue' do
  it_behaves_like 'a KeyValue'
  it_behaves_like 'a stored key'

  it 'increases it\'s value by 1 when calling #incr' do
    expect { subject.incr }.to change { subject.load!.to_i }.by(1)
  end

  it 'increases it\'s value by an arbitrary value when calling #incrby' do
    value = (rand * 10 + 1).ceil
    expect { subject.incrby(value) }.to change { subject.load!.to_i }.by(value)
  end
end

