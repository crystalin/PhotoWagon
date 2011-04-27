Feature: Home page display
  In order to read Alan Posts
  as a visitor
  I need to be able to see the posts

  Scenario: Visit the home page
    Given I am a visitor
    When I go to "the home page"
    Then I should see <div> within a div with class "cover_post"

  Scenario: Visit a post
    Given I am a visitor
    And I have a post with "IMGP9822.JPG"
    When I go to "the home page"
    And I follow "Diner chez Toshi"
    Then I should "Alan" within a div with class "photograph"