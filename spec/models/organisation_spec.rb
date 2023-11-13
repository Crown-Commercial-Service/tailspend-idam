require 'rails_helper'

RSpec.describe Organisation do
  describe 'search_organisations' do
    let(:result) { described_class.search_organisations(search) }

    before { described_class.create(organisation_name: search, active: active) }

    context 'when an active organisation is searched' do
      let(:search) { 'ACTIVE ORGANISATION 45' }
      let(:active) { true }

      it 'returns the organisation' do
        expect(result).to eq ['Active Organisation 45 (45 Test Road, Liverpool, AB1 2CD)']
      end
    end

    context 'when an non-active organisation is searched' do
      let(:search) { 'INACTIVE ORGANISATION' }
      let(:active) { false }

      it 'returns no organisations' do
        expect(result).to eq []
      end
    end
  end

  # rubocop:disable RSpec/NestedGroups
  describe '.summary_line' do
    let(:result) { described_class.find_by(organisation_name:).summary_line }

    context 'when the address is present' do
      context 'when the city is present' do
        context 'when the postcode is present' do
          let(:organisation_name) { 'Active Organisation 1' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 1 (1 Test Road, London, AB1 2CD)')
          end
        end

        context 'when the postcode is NULL' do
          let(:organisation_name) { 'Active Organisation 18' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 18 (18 Test Road, Newport)')
          end
        end

        context 'when the postcode is blank' do
          let(:organisation_name) { 'Active Organisation 15' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 15 (15 Test Road, Liverpool)')
          end
        end
      end

      context 'when the city is NULL' do
        context 'when the postcode is present' do
          let(:organisation_name) { 'Active Organisation 21' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 21 (21 Test Road, AB1 2CD)')
          end
        end

        context 'when the postcode is NULL' do
          let(:organisation_name) { 'Active Organisation 211' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 211 (211 Test Road)')
          end
        end

        context 'when the postcode is blank' do
          let(:organisation_name) { '(closed) Inactive Organisation 10' }

          it 'formats the summary_line properly' do
            expect(result).to eq('(closed) Inactive Organisation 10 (230 Test Road)')
          end
        end
      end

      context 'when the city is blank' do
        context 'when the postcode is present' do
          let(:organisation_name) { 'Active Organisation 216' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 216 (216 Test Road, MN7 8OP)')
          end
        end

        context 'when the postcode is NULL' do
          let(:organisation_name) { 'Active Organisation 9' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 9 (9 Test Road)')
          end
        end

        context 'when the postcode is blank' do
          let(:organisation_name) { 'Active Organisation 60' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 60 (60 Test Road)')
          end
        end
      end
    end

    context 'when the address is NULL' do
      context 'when the city is present' do
        context 'when the postcode is present' do
          let(:organisation_name) { 'Active Organisation 76' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 76 (London, MN7 8OP)')
          end
        end

        context 'when the postcode is NULL' do
          let(:organisation_name) { 'Active Organisation 17' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 17 (Birmingham)')
          end
        end

        context 'when the postcode is blank' do
          let(:organisation_name) { 'Active Organisation 129' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 129 (Norwich)')
          end
        end
      end

      context 'when the city is NULL' do
        context 'when the postcode is present' do
          let(:organisation_name) { 'Active Organisation 100' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 100 (MN7 8OP)')
          end
        end

        context 'when the postcode is NULL' do
          let(:organisation_name) { 'Active Organisation 22' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 22 (Birmingham)')
          end
        end

        context 'when the postcode is blank' do
          let(:organisation_name) { 'Active Organisation 33' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 33 (Newport)')
          end
        end
      end

      context 'when the city is blank' do
        context 'when the postcode is present' do
          let(:organisation_name) { 'Active Organisation 82' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 82 (EF3 4GH)')
          end
        end

        context 'when the postcode is NULL' do
          let(:organisation_name) { 'Active Organisation 87' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 87')
          end
        end

        context 'when the postcode is blank' do
          let(:organisation_name) { 'Active Organisation 117' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 117')
          end
        end
      end
    end

    context 'when the address is blank' do
      context 'when the city is present' do
        context 'when the postcode is present' do
          let(:organisation_name) { 'Active Organisation 10' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 10 (Liverpool, EF3 4GH)')
          end
        end

        context 'when the postcode is NULL' do
          let(:organisation_name) { 'Active Organisation 39' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 39 (Norwich)')
          end
        end

        context 'when the postcode is blank' do
          let(:organisation_name) { 'Active Organisation 16' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 16 (London)')
          end
        end
      end

      context 'when the city is NULL' do
        context 'when the postcode is present' do
          let(:organisation_name) { 'Active Organisation 199' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 199 (IJ5 6KL)')
          end
        end

        context 'when the postcode is NULL' do
          let(:organisation_name) { 'Active Organisation 24' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 24')
          end
        end

        context 'when the postcode is blank' do
          let(:organisation_name) { 'Active Organisation 30' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 30')
          end
        end
      end

      context 'when the city is blank' do
        context 'when the postcode is present' do
          let(:organisation_name) { 'Active Organisation 74' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 74 (EF3 4GH)')
          end
        end

        context 'when the postcode is NULL' do
          let(:organisation_name) { 'Active Organisation 31' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 31')
          end
        end

        context 'when the postcode is blank' do
          let(:organisation_name) { 'Active Organisation 79' }

          it 'formats the summary_line properly' do
            expect(result).to eq('Active Organisation 79')
          end
        end
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups
end
