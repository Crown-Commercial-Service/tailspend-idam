const lengthReg = () => new RegExp('^.{10,}');

const characterReg = () => new RegExp('[\\^\\$\\*\\.\\[\\]\\{\\}\\(\\)\\?"!@#%&\\/\\\\,><\':;\\|_~`=\\+-]');

const uppercaseReg = () => new RegExp('^(?=.*?[A-Z])');

const numberReg = () => new RegExp('^(?=.*[0-9])');

const passwordStrength = ($passwordField) => {
  const passwordTests = [
    {
      test: lengthReg(),
      $listItem: $('#passeight'),
    },
    {
      test: characterReg(),
      $listItem: $('#passchar'),
    },
    {
      test: uppercaseReg(),
      $listItem: $('#passcap'),
    },
    {
      test: numberReg(),
      $listItem: $('#passnum'),
    },
  ];

  $passwordField.on('keyup', () => {
    passwordTests.forEach((passwordTest) => {
      if (passwordTest.test.test($passwordField.val())) {
        passwordTest.$listItem.removeClass('wrong').addClass('correct');
      } else {
        passwordTest.$listItem.removeClass('correct').addClass('wrong');
      }
    });
  });
};

$(() => {
  if ($('#passwordrules').length) {
    const passwordID = $('#password_id').val();

    passwordStrength($(`#${passwordID}`));
  }
});
