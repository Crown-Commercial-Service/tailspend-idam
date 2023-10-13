require 'rails_helper'

RSpec.describe ApplicationHelper do
  let(:error_message_html) { '<span id="email-error" class="govuk-error-message govuk-!-margin-top-3">You must enter your email address in the correct format, like name@example.com</span>' }

  describe '.error_id' do
    let(:attribute) { ('a'..'z').to_a.sample(8).join }

    it 'creates the error ID' do
      expect(error_id(attribute)).to eq "#{attribute}-error"
    end
  end

  describe '.display_error' do
    let(:model) { Cognito::ForgotPassword.new(email) }
    let(:result) { display_error(model, :email) }

    before { model.valid? }

    context 'when there are no errors' do
      let(:email) { 'test@test.com' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end

    context 'when there are errors' do
      let(:email) { '' }

      it 'returns the error html' do
        expect(result).to eq(error_message_html)
      end
    end
  end

  describe '.page_title' do
    context 'when there is no additional title' do
      it 'returns just CCS' do
        expect(page_title).to eq 'Crown Commercial Services'
      end
    end

    context 'when there is an additional title' do
      before { content_for(:page_title, 'My Magical Title') }

      it 'returns CCS plus the additional title' do
        expect(page_title).to eq 'My Magical Title: Crown Commercial Services'
      end
    end
  end

  describe '.form_group_with_error' do
    let(:model) { Cognito::ForgotPassword.new('') }
    let(:result) do
      form_group_with_error(model, :email) do
        nil
      end
    end

    context 'when there is no error' do
      it 'creates the form group without the error' do
        expect(result).to eq('<div class="govuk-form-group" id="email-form-group"></div>')
        expect { |block| form_group_with_error(model, :email, &block) }.to yield_with_args(nil, false)
      end
    end

    context 'when there is an error' do
      before { model.valid? }

      it 'creates the form group with the error' do
        expect(result).to eq('<div class="govuk-form-group govuk-form-group--error" id="email-form-group"></div>')
        expect { |block| form_group_with_error(model, :email, &block) }.to yield_with_args(error_message_html, true)
      end
    end
  end

  describe '.cookie_preferences_settings' do
    let(:result) { helper.cookie_preferences_settings }
    let(:default_cookie_settings) do
      {
        'settings_viewed' => false,
        'usage' => false,
        'glassbox' => false
      }
    end

    context 'when the cookie has not been set' do
      it 'returns the default settings' do
        expect(result).to eq(default_cookie_settings)
      end
    end

    context 'when the cookie has been set' do
      before { helper.request.cookies['cookie_preferences'] = cookie_settings }

      context 'and it is a hash' do
        let(:expected_cookie_settings) do
          {
            'settings_viewed' => true,
            'usage' => true,
            'glassbox' => false
          }
        end
        let(:cookie_settings) { expected_cookie_settings.to_json }

        it 'returns the settings from the cookie' do
          expect(result).to eq(expected_cookie_settings)
        end
      end

      context 'and it is not a hash' do
        let(:cookie_settings) { '123' }

        it 'returns the default settings' do
          expect(result).to eq(default_cookie_settings)
        end
      end
    end
  end
end
