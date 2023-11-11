# this is really bad code and has issues.
DEFAULT_PASSWORD = ENV.fetch("DEFAULT_PASSWORD", "password")
CurrentUser.user = User.system
CurrentUser.ip_addr = "0.0.0.0"
def populate_users(n,password: DEFAULT_PASSWORD)
  n.times do |i|
    user = User.find_or_create_by!(name: "#{i.to_s}_user") do |user|
      user.created_at = 2.weeks.ago
      user.password = password
      user.password_confirmation = password
      user.password_hash = ""
      user.email = "user+#{i.to_s}@e621.net"
      user.level = User::Levels::MEMBER
    end
  end
end
def random_votes(n,post,users)
  n.times do |i|
    vote = rand(-1..1)
    u = User.find_by_name("#{rand(users)}_user")
    l = Post.find(post)
    if(vote==0)
      VoteManager.unvote!(user:u,post:l)
    else
      VoteManager.vote!(user:u,post:l,score:vote)
    end
  end
end
def do_many_votes(n)
  n.times do |i|
    z = rand(1..Post.count)
    l = Post.find(z).id
    m = rand(0..100)
    o = rand(0..100)
    random_votes(o,l,m)
  end
end
make = 100
populate_users(make)
do_many_votes(500)
