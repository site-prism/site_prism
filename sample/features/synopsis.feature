Feature: Synopsis Sample
  Example: display example
    When I navigate to the google home page
    Then the home page should contain the menu and the search form

  Example: input and expect example
    When I navigate to the google home page
    When I search for Sausages
    Then the search results page is displayed
    Then the search results page contains 10 individual search results
    Then the search results contain a link to the wikipedia sausages page
