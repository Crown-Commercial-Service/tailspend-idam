$(function () {
  var error_summary = $('.govuk-error-summary__list')

  if(error_summary.length) {
    var error_links = error_summary.find('li > a')
    error_links.each( function() {
      addFocusEvent(this);
    });
  }

  function addFocusEvent(error) {
    $(error).on('click', function (e) {
      $('html, body').animate({ scrollTop: $(error.hash).offset().top }, 0);
      getInputElement(error.hash).trigger('focus');
      e.preventDefault();
    });
  }

  function getInputElement(error_hash) {
    if (error_hash === "#organisation-error") {
      return $('#organisation')
    } else {
      return $(error_hash).nextAll('input').first()
    }
  }
});