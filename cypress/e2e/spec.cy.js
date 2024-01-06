describe('Resume Test', () => {
  it('Visits my resume site and makes sure it loads', () => {
    cy.visit('https://resume.chxnedu.online')

    cy.contains('Chinedu Oji')

  })
})