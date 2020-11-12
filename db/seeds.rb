User.destroy_all
Banker.destroy_all
Game.destroy_all

User.create(username: "Superman", balance: 10000)
User.create(username: "Batman", balance: 10000)

u1 = User.first
u2 = User.second

Banker.create(name: "Las Vegas", commission_rate: 0.95)
Banker.create(name: "Macau", commission_rate: 0.93)
Banker.create(name: "Meadowlands", commission_rate: 0.97)
Banker.create(name: "Home", commission_rate: 1)


b1 = Banker.first
b2 = Banker.second

#Game.create(user_id: u1.id, banker_id: b1.id)
