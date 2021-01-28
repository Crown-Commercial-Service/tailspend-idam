# frozen_string_literal: true

class HomeController < ApplicationController
  def index; end

  def accessibility_statement; end

  def cookie_settings
    cookies[:pmp_cookie_settings_viewed] = { value: 'true', expires: 1.year } if cookies[:pmp_cookie_settings_viewed].blank?
  end

  def cookie_policy; end
end
