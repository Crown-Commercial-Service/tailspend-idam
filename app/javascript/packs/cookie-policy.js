import Cookies from 'js-cookie';

const removeGACookies = () => {
  const cookieList = Object.keys(Cookies.get());
  const gaCookieList = [];

  for (let i = 0; i < cookieList.length; i++) {
    const cookieName = cookieList[i];

    if (cookieName.startsWith('_ga')
        || cookieName.startsWith('_gi')
        || cookieName.startsWith(' _ga')
        || cookieName.startsWith(' _gi')) gaCookieList.push(cookieName);
  }

  gaCookieList.forEach((cookieName) => Cookies.remove(cookieName));
};

document.addEventListener('DOMContentLoaded', () => {
  if (Cookies.get('pmp_cookie_settings_viewed') === 'true') $('#cookie-consent-container').hide();
  if (Cookies.get('pmp_google_analytics_enabled') !== 'true') removeGACookies();
});

$(() => {
  $('#accept-all-cookies').on('click', (e) => {
    e.preventDefault();

    Cookies.set('pmp_cookie_settings_viewed', 'true', { expires: 365 });
    Cookies.set('pmp_google_analytics_enabled', 'true', { expires: 365 });
    $('#cookie-options-container').hide();
    $('#cookies-accepted-container').show();
  });

  $('#save-cookie-settings-button').on('click', () => {
    if ($('input[name=ga_cookie_usage]:checked').val() === 'true') {
      Cookies.set('pmp_google_analytics_enabled', 'true', { expires: 365 });
    } else {
      Cookies.remove('pmp_google_analytics_enabled');
      removeGACookies();
    }

    $('#cookie-settings-saved').removeClass('govuk-visually-hidden');
    $('html, body').animate({ scrollTop: $('#cookie-settings-saved').offset().top }, 'slow');
  });
});
