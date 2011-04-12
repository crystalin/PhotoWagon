Feature: Post Management & Display
  In order to provide quality content
  As an author
  I need to be able to manage posts

  Scenario: Create Post with Image
    When I go to the posts creation page
    And I upload the test image "IMGP9822.JPG"
    And I press "Upload"
    Then I should see "Tamo"

  Scenario: Change Post information with Image
    Given I have a post with "IMGP9822.JPG"
    When I edit the post
    And I upload the test image "P1120383.JPG"
    And I press "Upload"
    Then I should not see "Tamo"
    Then I should see "Thailande"