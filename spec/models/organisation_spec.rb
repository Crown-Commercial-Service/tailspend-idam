require 'rails_helper'

RSpec.describe Organisation do
  describe 'find_organisation' do
    let(:result) { described_class.find_organisation(search) }

    before { described_class.create(supllier_name: search, active: active) }

    context 'when an active organisation is searched' do
      let(:search) { 'AN ACTIVE SUPPLIER' }
      let(:active) { true }

      it 'returns the organisation' do
        expect(result).to eq [search]
      end
    end

    context 'when an non-active organisation is searched' do
      let(:search) { 'INACTIVE SUPPLIER' }
      let(:active) { false }

      it 'returns no organisations' do
        expect(result).to eq []
      end
    end
  end
end
