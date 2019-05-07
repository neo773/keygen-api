@api/v1
Feature: Analytic counts

  Background:
    Given the following "accounts" exist:
      | Name    | Slug  |
      | Test 1  | test1 |
      | Test 2  | test2 |
    And I send and accept JSON

  Scenario: Endpoint should be inaccessible when account is disabled
    Given the account "test1" is canceled
    Given I am an admin of account "test1"
    And the current account is "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/analytics/actions/count"
    Then the response status should be "403"
    And sidekiq should have 0 "request-log" jobs

  Scenario: Admin retrieves analytic counts for their account
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 52 "users"
    And the current account has 12 "licenses"
    And the current account has 31 "machines"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/analytics/actions/count"
    Then the response status should be "200"
    And the JSON response should contain meta with the following:
      """
      {
        "licenses": $account.licenses.count,
        "machines": $account.machines.count,
        "users": $account.users.count
      }
      """
    And sidekiq should have 0 "request-log" jobs

  Scenario: User attempts to retrieve analytic counts for their account
    Given the current account is "test1"
    And the current account has 1 "user"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/analytics/actions/count"
    Then the response status should be "403"
    And the JSON response should be an array of 1 error
    And sidekiq should have 0 "request-log" jobs