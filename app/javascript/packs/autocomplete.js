import accessibleAutocomplete from 'accessible-autocomplete';

var pmp_auto_complete = {
  query: function(query, populateResults) {
    console.log(query);
    if (query.length > 3) {
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
    jQuery('.clear-selected').hide();
    organisation_input.attr('type', 'hidden');
    var autoComplete = accessibleAutocomplete({
      element: document.querySelector('#my-autocomplete-container'),
      id: 'my-autocomplete',
      source: pmp_auto_complete.query,
      name: 'anything[organisation_auto_complete]',
      minLength: 3,
      defaultValue: organisation_input.attr('value'),
      tNoResults: function() {
       return  "too many results";
      },
      onConfirm: function (query) {
        organisation_input.attr('value', query);
        jQuery('#selected-autocomplete-option p span').text(query);
        jQuery('.clear-selected').show();
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
    pmp_auto_complete.clear_selected();
  }
}
