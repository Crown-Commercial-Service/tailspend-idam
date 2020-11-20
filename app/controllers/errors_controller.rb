class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render status: 404, layout: 'error' }
    end
  end

  def unacceptable
    respond_to do |format|
      format.html { render status: 422, layout: 'error' }
    end
  end

  def internal_error
    respond_to do |format|
      format.html { render status: 500, layout: 'error' }
    end
  end
end
