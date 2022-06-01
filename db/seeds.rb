# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create([
  {nickname: "test3", email: "test3@test3.com"}
])

Task.create([
  {title: "Web系自社開発企業転職", content: "aaa", user_id: "1"},
  {title: "フリーランス月50万", content: "bbb", user_id: "1"},
  {title: "個人サービス月250万", content: "bbb", user_id: "1"}
])