User.destroy_all
Banker.destroy_all
Game.destroy_all

User.create(username: "Superman", balance: 10000)
User.create(username: "Batman", balance: 10000)

u1 = User.first
u2 = User.second

Banker.create(name: "Joker", commission_rate: 0.95)
Banker.create(name: "Zodd", commission_rate: 0.95)

b1 = Banker.first
b2 = Banker.second

Game.create(user_id: u1.id, banker_id: b1.id)
