@api/v1
Feature: Show webhook endpoint

  Background:
    Given the following "accounts" exist:
      | Company | Name  |
      | Test 1  | test1 |
      | Test 2  | test2 |
    And I send and accept JSON

  Scenario: Admin retrieves a webhook endpoint for their account
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 3 "webhookEndpoints"
    And I use an authentication token
    When I send a GET request to "/webhook-endpoints/$0"
    Then the response status should be "200"
    And the JSON response should be a "webhookEndpoint"

  Scenario: Admin attempts to retrieve a webhook endpoint for another account
    Given I am an admin of account "test2"
    But the current account is "test1"
    And the account "test1" has 3 "webhookEndpoints"
    And I use an authentication token
    When I send a GET request to "/webhook-endpoints/$0"
    Then the response status should be "401"
    And the JSON response should be an array of 1 error
