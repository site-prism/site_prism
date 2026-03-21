Feature: Page Navigation

  I want to be able to load and navigate around the web
  In order to interact with different pages

  Scenario: Load home page
    When I navigate to the home page
    Then I am on the home page

  Scenario: Load dynamic page
    When I navigate to the letter "A" page
    Then I am on a dynamic page

  Scenario: Load redirecting page
    When I navigate to the redirect page
    Then I am on the redirect page
    And I will be redirected to the home page

  Scenario: Load a page that redirects
    When I navigate to the home page
    Then I am not on the redirect page

  Scenario: Navigating to a different page
    When I navigate to the home page
    And I click the go button
    Then I will be redirected to the page without a title

  Scenario: Load a Page that has no load validations
    When I navigate a page with no load validations
    Then I am not made to wait to continue

  Scenario: Load a Page that has load validations set
    When I navigate a page with load validations
    Then I am made to wait to continue

  Scenario: Load a Page that has failing load validations
    Then an error is thrown when loading a page with failing validations
    And the crash page will not be marked as loaded

  Scenario: Load a Page that has failing load validations without validations
    Then no error is thrown when loading a page whilst skipping load validations
    And the crash page will be marked as loaded

  Scenario: Re-run load validations on a page - Positive
    When I navigate to the letter "A" page
    And I navigate to the home page
    And I click the link for the letter "A" page
    Then no error is raised when re-running load validations for the dynamic page
    And the dynamic page will be marked as loaded

  Scenario: Re-run load validations on a page - Negative
    When I navigate to the letter "A" page
    And I navigate to the home page
    Then a load validation error is raised when re-running load validations for the dynamic page
    And the dynamic page will not be marked as loaded
