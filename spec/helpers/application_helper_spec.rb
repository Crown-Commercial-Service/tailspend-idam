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
        expect(result).to be nil
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
end
