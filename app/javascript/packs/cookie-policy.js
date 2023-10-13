import Cookies from "js-cookie";

const cookieUpdateOptions = [
  {
    cookieName: 'usage',
    cookiePrefixes: ['_ga', '_gi'],
  },
  {
    cookieName: 'glassbox',
    cookiePrefixes: ['_cls'],
  },
];

const getCookiePreferences = () => {
  const defaultCookieSettings = '{"usage":true,"glassbox":false}';

  return JSON.parse(Cookies.get('crown_marketplace_cookie_options_v1') || defaultCookieSettings);
};

const removeUnwantedCookies = () => {
  const cookieList = Object.keys(Cookies.get());
  const cookiesToRemove = ['tailspend_cookie_settings_viewed', 'tailspend_google_analytics_enabled', 'tailspend_cookie_options_v1'];
  const cookiePreferences = getCookiePreferences();
  const cookiePrefixes = [];

  cookieUpdateOptions.forEach((cookieUpdateOption) => {
    if (!cookiePreferences[cookieUpdateOption.cookieName]) cookiePrefixes.push(...cookieUpdateOption.cookiePrefixes);
  });

  for (let i = 0; i < cookieList.length; i++) {
    const cookieName = cookieList[i];

    if (cookiePrefixes.some((cookiePrefix) => cookieName.startsWith(cookiePrefix))) cookiesToRemove.push(cookieName);
  }

  cookiesToRemove.forEach((cookieName) => Cookies.remove(cookieName, { path: '/', domain: '.crowncommercial.gov.uk' }));
};

const removeGACookies = (formData, successFunction) => {
  let success = false;

  $.ajax({
    type: 'GET',
    url: '/cookie-settings/update',
    data: formData,
    dataType: 'json',
    success() {
      success = true;
    },
    complete() {
      if (success) successFunction();
    },
  });
};

const cookiesSaved = () => {
  $('#cookie-settings-saved').show();
  $('html, body').animate({ scrollTop: $('#cookie-settings-saved').offset().top }, 'slow');
};

const cookieSettingsViewed = ($newBanner) => {
  $('#cookie-options-container').hide();
  $newBanner.show();
};

const updateBanner = (isAccepeted, $newBanner) => {
  removeGACookies(
    {
      ga_cookie_usage: isAccepeted,
      glassbox_cookie_usage: isAccepeted,
    },
    cookieSettingsViewed.bind(null, $newBanner),
  );
};

$(() => {
  removeUnwantedCookies();

  $('[name="cookies"]').on('click', (event) => {
    event.preventDefault();

    const buttonValue = event.currentTarget.value;

    updateBanner(buttonValue === 'accept', $(`#cookies-${buttonValue}ed-container`));
  });

  const $form = $('#update-cookie-setings');

  $form.on('submit', (event) => {
    event.preventDefault();

    $('#cookie-settings-saved').show();

    const formData = Object.fromEntries($form.serializeArray().map((element) => [element.name, element.value]));

    removeGACookies(
      formData,
      cookiesSaved,
    );
  });
});
