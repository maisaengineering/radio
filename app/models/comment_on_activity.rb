class CommentOnActivity < ActiveRecord::Base
	belongs_to :comment
	belongs_to :user
	belongs_to :favorite
	belongs_to :song
end
