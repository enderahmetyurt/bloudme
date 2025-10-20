require 'faker'

# Only clear data in development environment
if Rails.env.development?
  Feed.destroy_all
  Article.destroy_all
  puts "✓ Cleared existing feeds and articles"
end

# Create or find user with random password
user = User.find_or_create_by(email_address: "foobar@test.com")
password = Faker::Internet.password(min_length: 10, max_length: 20)

user.password = password
user.password_confirmation = password
user.save!
user.confirm_email!

puts "✓ User created: #{user.email_address}"
puts "  Password: #{password}"

20.times do
  feed = Feed.create!(
    title: Faker::Company.name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    site_url: "https://#{Faker::Internet.domain_name}",
    feed_url: "https://#{Faker::Internet.domain_name}/feed.xml",
    favicon: Faker::LoremFlickr.image(size: '32x32'),
    is_podcast: [true, false, nil].sample,
    user: user
  )

  # Create 5 articles for each feed
  5.times do
    Article.create!(
      feed: feed,
      title: Faker::Lorem.sentence(word_count: 8),
      link: "https://#{Faker::Internet.domain_name}/article/#{Faker::Number.number(digits: 5)}",
      content: "<p>#{Faker::Lorem.paragraphs(number: 3).join('</p><p>')}</p>",
      published_at: Faker::Time.backward(days: 365),
      created_at: Faker::Time.backward(days: 365),
      thumbnail: [Faker::LoremFlickr.image, nil].sample,
      is_read: [true, false].sample
    )
  end
end
