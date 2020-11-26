import accessibleAutocomplete from 'accessible-autocomplete';

var no_results = false;

var pmp_auto_complete = {
  autocomplete_int: [],

  query: function(query, populateResults) {
    if (query.length > 2) {
      $.ajax({
        url: '/api/v1/organisation-search',
        type: 'post',
        data: {
          search: query,
        },
        success: function (response) {
          populateResults(response['supplier_names']);
          no_results = response['no_results'];
        },
        error: function (xhr) {},
      });
    }
  },

  initiante_auto_complete: function() {
    pmp_auto_complete.autocomplete_int = accessibleAutocomplete({
      element: document.querySelector('#my-autocomplete-container'),
      id: 'organisation-input',
      source: pmp_auto_complete.query,
      name: 'anything[organisation-input]',
      minLength: 3,
      defaultValue: $('#organisation').val(),
      showNoOptionsFound: true,
      tNoResults: function() {
        if (no_results) {
          return "No results found"
        } else {
          return  "Search for a more specific term";
        }
      },
      onConfirm: function (query) {
        if (query !== undefined) {
          $('#organisation').val(query)
          $('#selected-autocomplete-option').show();
          $('#selected-autocomplete-option p span').text(query);
        }
      },
    });

    $('#organisation-input').on('keyup', function(e) {
      if ($(e.target).val() !== $('#selected-autocomplete-option p span').text()) {
        $('#organisation').val('')
        $('#selected-autocomplete-option').hide();
        $('#selected-autocomplete-option p span').text('');
      }
    });
  }
}

window.onload = function () {
  if($('#my-autocomplete-container').length > 0) {
    pmp_auto_complete.initiante_auto_complete();
  }
}
