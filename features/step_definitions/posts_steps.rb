Given /^I have a post with "([^"]*)"$/ do |image|
  @post = Post.create(:image => image)
  @post.save!
end

When /^I display the post$/ do
  visit "/posts/#{@post.id}"
end

When /^I edit the post$/ do
  visit "/posts/#{@post.id}/edit"
end

When /^I upload the test image "([^"]*)"$/ do |image|
  attach_file("post_image", File.join(::Rails.root, "features/images/", image))
end

# MiniExiftool.new File.join(::Rails.root, "features/images/", 'test.jpg')