require 'rails_helper'

RSpec.describe Api::V1::OrganisationController do
  describe 'GET search' do
    let(:result) { JSON.parse(response.body) }

    before { get :search, params: { search: search } }

    context 'when an active organisation is searched' do
      let(:search) { 'Active Supplier 200' }

      it 'returns the organisation' do
        expect(result['supplier_names']).to eq [search]
      end

      it 'returns no_results as false' do
        expect(result['no_results']).to eq false
      end
    end

    context 'when an non-active organisation is searched' do
      let(:search) { 'Inactive Supplier' }

      it 'returns no organisations' do
        expect(result['supplier_names']).to eq []
      end

      it 'returns no_results as true' do
        expect(result['no_results']).to eq true
      end
    end

    context 'when an active organisation is searched with over 200 results' do
      let(:search) { 'Active Supplier' }

      it 'returns the organisation' do
        expect(result['supplier_names']).to eq []
      end

      it 'returns no_results as false' do
        expect(result['no_results']).to eq false
      end
    end

    context 'when a non existentorganisation is searched' do
      let(:search) { 'CCS' }

      it 'returns no organisations' do
        expect(result['supplier_names']).to eq []
      end

      it 'returns no_results as true' do
        expect(result['no_results']).to eq true
      end
    end
  end
end
