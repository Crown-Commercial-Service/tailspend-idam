require 'rails_helper'

RSpec.describe HomeController do
  describe 'GET accessibility_statement' do
    it 'renders the accessibility_statement page' do
      get :accessibility_statement

      expect(response).to render_template(:accessibility_statement)
    end
  end

  describe 'GET cookie_policy' do
    it 'renders the cookie policy page' do
      get :cookie_policy

      expect(response).to render_template(:cookie_policy)
    end
  end

  describe 'GET cookie_settings' do
    it 'renders the cookie settings page' do
      get :cookie_settings

      expect(response).to render_template(:cookie_settings)
    end
  end

  describe 'PUT update_cookie_settings' do
    let(:cookie_names) { response.cookies.map { |cookie_name, _| cookie_name } }

    before do
      %i[_ga_cookie _gi_cookie _cls_cookie].each do |cookie_name|
        cookies[cookie_name] = { value: 'test_cookie', domain: '.crowncommercial.gov.uk', path: '/' }
      end

      get :update_cookie_settings, params: update_params
    end

    context 'when enableing the ga cookies and disableing the glassbox cookies' do
      let(:update_params) { { ga_cookie_usage: 'true', glassbox_cookie_usage: 'false' } }

      it 'updates the cookie preferences' do
        expect(JSON.parse(response.cookies['cookie_preferences'])).to eq(
          {
            'settings_viewed' => true,
            'usage' => true,
            'glassbox' => false
          }
        )
      end

      it 'does not delete the ga cookies' do
        %w[_ga_cookie _gi_cookie].each do |cookie_name|
          expect(cookie_names).not_to include cookie_name
        end
      end

      it 'does delete the glassbox cookies' do
        %w[_cls_cookie].each do |cookie_name|
          expect(cookie_names).to include cookie_name

          expect(response.cookies[cookie_name]).to be_nil
        end
      end

      it 'updates the cookies_updated param' do
        expect(controller.params[:cookies_updated]).to be true
      end

      it 'renders the cookie_settings template' do
        expect(response).to render_template('home/cookie_settings')
      end
    end

    context 'when enableing the glassbox cookies and disableing the ga cookies' do
      let(:update_params) { { ga_cookie_usage: 'false', glassbox_cookie_usage: 'true' } }

      it 'updates the cookie preferences' do
        expect(JSON.parse(response.cookies['cookie_preferences'])).to eq(
          {
            'settings_viewed' => true,
            'usage' => false,
            'glassbox' => true
          }
        )
      end

      it 'does not delete the glassbox cookies' do
        %w[_cls_cookie].each do |cookie_name|
          expect(cookie_names).not_to include cookie_name
        end
      end

      it 'does delete the ga cookies' do
        %w[_ga_cookie _gi_cookie].each do |cookie_name|
          expect(cookie_names).to include cookie_name

          expect(response.cookies[cookie_name]).to be_nil
        end
      end

      it 'updates the cookies_updated param' do
        expect(controller.params[:cookies_updated]).to be true
      end

      it 'renders the cookie_settings template' do
        expect(response).to render_template('home/cookie_settings')
      end
    end

    context 'when enableing the ga cookies and the glassbox cookies' do
      let(:update_params) { { ga_cookie_usage: 'true', glassbox_cookie_usage: 'true' } }

      it 'updates the cookie preferences' do
        expect(JSON.parse(response.cookies['cookie_preferences'])).to eq(
          {
            'settings_viewed' => true,
            'usage' => true,
            'glassbox' => true
          }
        )
      end

      it 'does not delete the ga and glassbox cookies' do
        %w[_ga_cookie _gi_cookie _cls_cookie].each do |cookie_name|
          expect(cookie_names).not_to include cookie_name
        end
      end

      it 'updates the cookies_updated param' do
        expect(controller.params[:cookies_updated]).to be true
      end

      it 'renders the cookie_settings template' do
        expect(response).to render_template('home/cookie_settings')
      end
    end

    context 'when disableing the ga cookies and the glassbox cookies' do
      let(:update_params) { { ga_cookie_usage: 'false', glassbox_cookie_usage: 'false' } }

      it 'updates the cookie preferences' do
        expect(JSON.parse(response.cookies['cookie_preferences'])).to eq(
          {
            'settings_viewed' => true,
            'usage' => false,
            'glassbox' => false
          }
        )
      end

      it 'does delete the ga and glassbox cookies' do
        %w[_ga_cookie _gi_cookie _cls_cookie].each do |cookie_name|
          expect(cookie_names).to include cookie_name

          expect(response.cookies[cookie_name]).to be_nil
        end
      end

      it 'updates the cookies_updated param' do
        expect(controller.params[:cookies_updated]).to be true
      end

      it 'renders the cookie_settings template' do
        expect(response).to render_template('home/cookie_settings')
      end
    end
  end
end