const cReg = /^.{10,}/
const uReg = /^(?=.*?[A-Z])/
const lReg = /^(?=.*?[a-z])/
const numReg = /^(?=.*[0-9])/
const symReg = /^(?=.*?[=+\-^$*.[\]{}()?"!@#%&/,><':;|_~`])/

const runTests = ($input: JQuery<HTMLElement>, theTests: Array<[RegExp, JQuery<HTMLElement>]>): void => {
  const inputText = String($input.val())

  theTests.forEach((test) => {
    const testPassed: boolean = test[0].test(inputText)

    test[1].toggleClass('wrong', !testPassed)
    test[1].toggleClass('correct', testPassed)
  })
}

const passwordStrength = ($input: JQuery<HTMLElement>, theTests: Array<[RegExp, JQuery<HTMLElement>]>): void => {
  $input.on('keyup', () => { runTests($input, theTests) })
}

const initPasswordStrength = (): void => {
  if ($('#passwordrules').length) {
    const theTests: Array<[RegExp, JQuery<HTMLElement>]> = [
      [cReg, $('#passeight')],
      [uReg, $('#passcap')],
      [lReg, $('#passlower')],
      [numReg, $('#passnum')],
      [symReg, $('#passsym')]
    ]

    const passwordID = $('#password_id').val()

    passwordStrength($(`#${passwordID}`), theTests)
  }
}

export default initPasswordStrength
