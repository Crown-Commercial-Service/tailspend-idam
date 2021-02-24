require 'rails_helper'

RSpec.describe ApplicationController do
  describe '.get_error_list' do
    let(:object) { Cognito::SignUpUser.new(nil, nil, nil, nil, nil, nil) }
    let(:errors_object) { object.errors }

    context 'when the object has one attribute with one error' do
      before { errors_object.add(:password, :blank) }

      it 'formats the errors correctly' do
        expect(controller.get_error_list(errors_object)).to eq({ password: [:blank] })
      end
    end

    context 'when the object has multiple attributes with one error' do
      before do
        errors_object.add(:password, :invalid)
        errors_object.add(:first_name, :too_short)
      end

      it 'formats the errors correctly' do
        expect(controller.get_error_list(errors_object)).to eq({ password: [:invalid], first_name: [:too_short] })
      end
    end

    context 'when the object has multiple attributes with multiple errors' do
      before do
        errors_object.add(:password, :invalid_no_capitals)
        errors_object.add(:first_name, :too_short)
        errors_object.add(:password, :invalid_symbol)
        errors_object.add(:email, :blank)
      end

      it 'formats the errors correctly' do
        expect(controller.get_error_list(errors_object)).to eq({ password: %i[invalid_no_capitals invalid_symbol], first_name: %i[too_short], email: %i[blank] })
      end
    end
  end
end
