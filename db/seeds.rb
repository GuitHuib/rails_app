# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Create seed user tamplate
User.create( name:    "Ryan",
             email:   "example@example.com",
             password:              "password",
             password_confirmation: "password",
             admin: true,
             activated: true,
             activated_at: Time.zone.now )

# Create additional users
99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@example.com"
  password = "password"
  User.create( name:     name,
               email:    email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now )
end

# Generate microposts
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.microposts.create!(content: content) }
end

# Create relationships
users = User.all
user  = users.first
following = users[2..37]
followers = users[4..24]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
