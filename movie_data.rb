class MovieData
    attr_reader :user_entry, :movie_entry

    def initialize()
      @user_entry = Hash.new
      @movie_entry = Hash.new
    end

    #Read data
    def load_data()
        File.open("u.data","r") do |file|
            while line = file.gets
                #get four attr from one line
                user_id, movie_id, rating, timestamp = line.chomp.split(' ')
                #create hash
                #hash with user_id as the entry point
                @user_entry[:"#{user_id}"] ||= Hash.new
                @user_entry[:"#{user_id}"][:"#{movie_id}"] = {:rating => rating.to_i, :timestamp => timestamp.to_i}
                #hash with movie_id as the entry point
                @movie_entry[:"#{movie_id}"] ||= Hash.new
                @movie_entry[:"#{movie_id}"][:"#{user_id}"] = {:rating => rating.to_i, :timestamp => timestamp.to_i}
            end
        end
    end

    def popularity(movie_id)
        popularity = 0
        @movie_entry[:"#{movie_id}"].each do |user_id, record|
            popularity += record[:rating]
        end
        return popularity
    end

    def popularity_list()
        pop_list = Hash.new
        @movie_entry.each do |movie_id, record|
            pop_list[movie_id] = popularity(movie_id.to_s.to_i)
        end
        return pop_list.sort_by {|k, v| v}.reverse.to_h
    end

    def similarity(user1, user2)
        sum = 0.0
        len1 = 0.0
        len2 = 0.0
        @user_entry[:"#{user1}"].each do |movie_id, record|
            if(@user_entry[:"#{user2}"][movie_id])
                 sum += record[:rating] * @user_entry[:"#{user2}"][movie_id][:rating]
            end
            len1 += record[:rating] ** 2
        end
        @user_entry[:"#{user2}"].each do |movie_id, record|
            len2 += record[:rating] ** 2
        end
        return sum / Math.sqrt(len1 * len2)
    end

    def most_similar(u)
        sim_list = Hash.new
        @user_entry.each do |user_id, record|
            sim_list[user_id] = similarity(u, user_id)
        end
        return sim_list.sort_by {|k, v| v}.reverse.to_h
    end
end

movie_data = MovieData.new
movie_data.load_data()

puts "first 10 elements of popularity list:"
puts movie_data.popularity_list().first(10).to_h
puts "last 10 elements of popularity list:"
puts movie_data.popularity_list().to_a.last(10).to_h
puts "first 10 elements of similarity list:"
puts movie_data.most_similar(1).first(10).to_h
puts "last 10 elements of similarity list:"
puts movie_data.most_similar(1).to_a.last(10).to_h
