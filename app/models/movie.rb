class Movie < ApplicationRecord
    validates :title, :genre, :country, :year, presence: true
end