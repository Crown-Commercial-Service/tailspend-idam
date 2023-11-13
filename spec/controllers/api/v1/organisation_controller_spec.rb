require 'rails_helper'

RSpec.describe Api::V1::OrganisationController do
  describe 'GET search' do
    let(:result) { response.parsed_body }

    before { get :search, params: { search: } }

    context 'when an active organisation is searched' do
      let(:search) { 'Active Organisation 200' }

      it 'returns the organisation summary line' do
        expect(result['summary_lines']).to eq ['Active Organisation 200 (200 Test Road, Liverpool, MN7 8OP)']
      end

      it 'returns no_results as false' do
        expect(result['no_results']).to be false
      end
    end

    context 'when an non-active organisation is searched' do
      let(:search) { 'Inactive Organisation' }

      it 'returns no organisations' do
        expect(result['summary_lines']).to eq []
      end

      it 'returns no_results as true' do
        expect(result['no_results']).to be true
      end
    end

    context 'when an active organisation is searched with over 200 results' do
      let(:search) { 'Active Organisation' }

      it 'returns the organisation' do
        expect(result['summary_lines']).to eq []
      end

      it 'returns no_results as false' do
        expect(result['no_results']).to be false
      end
    end

    context 'when a non existent organisation is searched' do
      let(:search) { 'CCS' }

      it 'returns no organisations' do
        expect(result['summary_lines']).to eq []
      end

      it 'returns no_results as true' do
        expect(result['no_results']).to be true
      end
    end
  end
end
