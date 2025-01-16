require "faker"

20.times do
  User.create(
    nick_name: "",
    email_address: Faker::Internet.email,
    password: "password",
    password_confirmation: "password"
  )
end

100.times do
  sentence = Faker::Lorem.sentence.truncate(rand(10..99), separator: ' ')
  paragraph = Faker::Lorem.paragraph.truncate(rand(50..399), separator: ' ')
  date = Faker::Date.between(from: 1.month.ago, to: Date.today)

  Post.create(
    title: sentence,
    content: paragraph,
    user_id: User.all.sample.id,
    published: [ true, false ].sample,
    created_at: date,
    updated_at: date,
  )
end
