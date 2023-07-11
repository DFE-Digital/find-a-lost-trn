import { initAll } from "govuk-frontend";
import dfeAutocomplete from "dfe-autocomplete";

initAll();
dfeAutocomplete({ autoselect: false });

// In order to allow the autocomplete to work as a free text field, we need to
// prevent the select element (that has the same name as the input field) from
// being submitted.
function disableIttProviderSelect() {
  var $ittProviderSelect = document.querySelector(
    'select[name="itt_provider_form[itt_provider_name]"',
  );
  if (!$ittProviderSelect) return;

  $ittProviderSelect.name = "";
}
disableIttProviderSelect();
