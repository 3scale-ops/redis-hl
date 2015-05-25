RSpec.shared_examples_for 'a collection' do
  [:include?, :has_key?, :count, :each,
   :get, :set, :scan, :typeof, :collection?].each do |m|
    it { is_expected.to respond_to(m) }
  end

  it { is_expected.to be_a(Enumerable) }
end

RSpec.shared_examples_for 'a non-root collection' do
  it_behaves_like 'non-root'
  it_behaves_like 'a collection'
end

RSpec.shared_examples_for 'a non-root stored collection' do
  it_behaves_like 'non-root'
  it_behaves_like 'stored'
  it_behaves_like 'a collection'
end
