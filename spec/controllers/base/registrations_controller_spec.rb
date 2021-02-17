require 'rails_helper'

RSpec.describe Base::RegistrationsController do
  describe 'GET new' do
    before { get :new }

    it 'renders the new page' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    let(:email) { 'test@testemail.com' }
    let(:first_name) { 'John' }

    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Cognito::SignUpUser).to receive(:create_cognito_user).and_return({ 'user_sub': '1234567890' })
      # rubocop:enable RSpec/AnyInstance
      AllowedEmailDomain.create(url: 'testemail.com', active: true)
      post :create, params: { anything: { email: email, first_name: first_name, last_name: 'Smith', password: 'Password890!', password_confirmation: 'Password890!', organisation: 'Active Supplier 1' } }
    end

    context 'when the emaildomain is not on the allow list' do
      let(:email) { 'test@fake-testemail.com' }

      it 'redirects to base_domain_not_on_allow_list_path' do
        expect(response).to redirect_to base_domain_not_on_allow_list_path
      end
    end

    context 'when some of the information is invalid' do
      let(:first_name) { '' }

      it 'renders the new page' do
        expect(response).to render_template(:new)
      end
    end

    context 'when all the information is valid' do
      it 'redirects to base_users_confirm_path' do
        expect(response).to redirect_to base_users_confirm_path(email: email)
      end
    end
  end

  describe 'GET domain_not_on_allow_list' do
    before { get :domain_not_on_allow_list }

    it 'renders the new page' do
      expect(response).to render_template(:domain_not_on_allow_list)
    end
  end
end
