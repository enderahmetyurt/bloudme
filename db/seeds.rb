require "faker"

15.times do
  User.create(
    nick_name: "",
    email_address: Faker::Internet.email,
    password: "password",
    password_confirmation: "password"
  )
end

30.times do
  Post.create(
    title: Faker::Lorem.sentence,
    content: Faker::Lorem.paragraph,
    user_id: User.all.sample.id,
    published: [ true, false ].sample
  )
end
