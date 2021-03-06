User.extend(Spawn).spawner do |user|
  user.name     ||= Faker::Name.name
  user.nickname ||= Faker::Internet.user_name
end

MatchPrediction.extend(Spawn).spawner do |prediction|
  prediction.host_score  ||= (0..9).to_a.sample
  prediction.rival_score ||= (0..9).to_a.sample
end

Result.extend(Spawn).spawner do |result|
  result.host_score  ||= (0..9).to_a.sample
  result.rival_score ||= (0..9).to_a.sample
  result.status      ||= 'partial'
end

Group.extend(Spawn).spawner do |group|
  group.name        ||= Faker::Lorem.words(2)
  group.description ||= Faker::Lorem.sentence
end

GroupsUser.extend(Spawn).spawner do |groupuser|
  groupuser.group_id ||= Group.spawn.id
  groupuser.user_id  ||= User.spawn.id
end

Match.extend(Spawn).spawner do |match|
  match.start_datetime ||= Time.now
  match.place          ||= "here"
  match.stadium        ||= "there"
  match.local_timezone ||= "GMT-3"
end
