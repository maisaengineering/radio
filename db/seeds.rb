# puts "Seeding Genres"
# Genre.destroy_all
# ["Rock",
#  "Rap",
#  "Indie",
#  "Pop",
#  "Techno",
#  "Trance",
#  "Drum & Bass",
#  "Dubstep",
#  "Hip-Hop",
#  "Indie",
#  "Singer/Songwriter",
#  "Country",
#  "Soundtrack",
#  "Alternative",
#  "House",
#  "Electronica",
#  "Ambient",
#  "R&B",
#  "Soul",
#  "Jazz",
#  "Acid Jazz",
#  "Trip-Hop",
#  "Blues",
#  "Folk",
#  "Funk",
#  "Bluegrass",
#  "Reggae",
#  "Pop-Rock",
#  "J-Pop"
# ].each {|genre| Genre.create :name => genre }

# puts "Seeding Artists"
# Artist.destroy_all
# [ { :name => "Band of Horses",
#     :genres => ["Indie", "Rock"]},
#   { :name => "The Stills",
#     :genres => ["Rock"]},
#   { :name => "Muse",
#     :genres => ["Rock"]},
#   { :name => "Blues Traveler", 
#     :genres => ["Rock", "Folk"]},
#   { :name => "Green Day", 
#     :genres => ["Rock", "Alternative"]},
#   { :name => "She Beards", 
#     :genres => ["Pop-Rock"]},
#   { :name => "Maggie Finan",
#     :genres => ["Singer/Songwriter", "Folk"]},
#   { :name => "Wendy Darling",
#     :genres => ["Rock", "Pop-Rock", "Alternative"]},
#   { :name => "The Grouch", 
#     :genres => ["Rap", "Hip-Hop"]},
#   { :name => "Tony Sano",
#     :genres => ["Singer/Songwriter", "Electronica"]}
# ].each do |artist|
#   artist_record = Artist.create :name => artist[:name]
#   artist[:genres].each {|genre| artist_record.genres << Genre.find_by_name(genre) }
# end

# puts "Seeding Songs"
# Song.destroy_all
# [ { :artist => "Band of Horses",
#     :name => "Funeral",
#     :genres => ["Rock", "Indie"]},
#   { :artist => "The Stills",
#     :name => "Panic",
#     :genres => ["Rock"]},
#   { :artist => "Muse",
#     :name => "Invincible", 
#     :genres => ["Rock"]},
#   { :artist => "Blues Traveler", 
#     :name => "Hook",
#     :genres => ["Rock", "Folk"]},
#   { :artist => "Green Day",
#     :name => "Dookie",
#     :genres => ["Rock", "Alternative"]},
#   { :artist => "She Beards",
#     :name => "Sister Song",
#     :genres => ["Pop-Rock"]},
#   { :artist => "Maggie Finan",
#     :name => "Say",
#     :genres => ["Singer/Songwriter", "Folk"]},
#   { :artist => "Wendy Darling",
#     :name => "Diamond In The Rough",
#     :genres => ["Rock", "Pop-Rock", "Alternative"]},
#   { :artist => "The Grouch",
#     :name => "Do It Again",
#     :genres => ["Rap", "Hip-Hop"]},
#   { :artist => "Tony Sano",
#     :name => "There You Are",
#     :genres => ["Singer/Songwriter", "Electronica" ]}    
# ].each do |song|
#   song_record = Artist.find_by_name(song[:artist]).songs.create :title => song[:name]
#   song[:genres].each {|g| song_record.genres << Genre.find_by_name(g) }
# end
