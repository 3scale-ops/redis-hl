RSpec.shared_examples_for 'a SimpleKey' do
  it 'has type of :simplekey' do
    expect(subject.type).to be(:simplekey)
  end

  [:value, :value=].each do |m|
    it { is_expected.not_to respond_to(m) }
  end
end
