ActiveAdmin.register RecentActivity do
  filter :user
  index :as => :block do |recent|
  	table do
      tr :for => recent do
        td do
      	  if recent.activity_type == "Comment"
            span :style=>"font-weight:bold;" do (link_to recent.user.username, "/admin/users/"+recent.user_id) end 
            span " commented on "
            span :style=>"font-weight:bold;" do Song.find(recent.song_id).title end
            span " :-- " + recent.activity
          elsif recent.activity_type == "Favorite" && recent.activity == "unfavorite"
            span :style=>"font-weight:bold;" do (link_to recent.user.username, "/admin/users/"+recent.user_id) end
            span " removed " 
            span :style=>"font-weight:bold;" do Song.find(recent.song_id).title end
            span " from his favorites."
          elsif recent.activity_type == "Favorite" && recent.activity == "favorite"
            span :style=>"font-weight:bold;" do (link_to recent.user.username, "/admin/users/"+recent.user_id) end
            span " added " 
            span :style=>"font-weight:bold;" do Song.find(recent.song_id).title end
            span " to his favorites."
          elsif recent.activity_type == "Login" && recent.activity == "logged in"
            span :style=>"font-weight:bold;" do (link_to recent.user.username, "/admin/users/"+recent.user_id) end 
            span " logged in to ishlist."
          elsif recent.activity_type == "Login" && recent.activity == "admin logged in"
            span :style=>"font-weight:bold;" do (link_to recent.user.username, "/admin/users/"+recent.user_id) end
            span " logged in as"
            span :style=>"font-weight:bold;" do " Admin" end
            span " to ishlist."
          elsif recent.activity_type == "Register"
            span :style=>"font-weight:bold;" do (link_to recent.user.username, "/admin/users/"+recent.user_id) end
            span " created a new account at ishlist."
          elsif recent.activity_type == "Share"
            span :style=>"font-weight:bold;" do (link_to recent.user.username, "/admin/users/"+recent.user_id) end
            span " shared track " 
            span :style=>"font-weight:bold;" do Song.find(recent.song_id).title end
            span " with Ishlist."
          end
        end
        td :style => "float:right;width: 120px;" do
          span :style => "float:right;" do distance_of_time_in_words(recent.created_at, Time.now) + " ago" end
        end
      end
    end
  end

end
