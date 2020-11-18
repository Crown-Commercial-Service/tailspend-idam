import accessibleAutocomplete from 'accessible-autocomplete';

var pmp_auto_complete = {
  autocomplete_int: [],
  query: function(query, populateResults) {
    if (query.length > 2) {
      jQuery.ajax({
        url: '/api/v1/organisation-search',
        type: 'post',
        data: {
          search: query,
        },
        success: function (response) {
          populateResults(response);
        },
        error: function (xhr) {},
      });
    }
  },

  initiante_auto_complete: function() {
    var organisation_input = jQuery('#organisation');
    if(organisation_input.attr('value').length == 0) {
      jQuery('#selected-autocomplete-option').hide();
    }
    organisation_input.attr('type', 'hidden');
    pmp_auto_complete.autocomplete_int = accessibleAutocomplete({
      element: document.querySelector('#my-autocomplete-container'),
      id: 'organisation',
      source: pmp_auto_complete.query,
      name: 'anything[organisation_auto_complete]',
      minLength: 2,
      defaultValue: organisation_input.attr('value'),
      showNoOptionsFound: true,
      tNoResults: function() {
       return  "search for more specific term";
      },
      onConfirm: function (query) {
        organisation_input.attr('value', query);
        jQuery('#selected-autocomplete-option').show();
        jQuery('#selected-autocomplete-option p span').text(query);
      },
    });
  },
  clear_selected: function() {
    jQuery('.clear-selected').on('click', function(e) {
      e.preventDefault();
        jQuery('#organisation').attr('value', '');
        jQuery('#selected-autocomplete-option p span').text('');
        jQuery('.autocomplete__input').val('')
        jQuery('.clear-selected').hide();
    })
  }
}

window.onload = function () {
  if($('#my-autocomplete-container').length > 0) {
    pmp_auto_complete.initiante_auto_complete();
  }
}
