  namespace :ishlist do

    task :change_all_collations do
      database_platform = YAML.load_file(File.join("config/database.yml"))["#{Rails.env}"]
      ActiveRecord::Base.establish_connection(database_platform)
      ActiveRecord::Base.connection.execute("ALTER DATABASE `#{database_platform['database']}` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin\;")
      ActiveRecord::Base.connection.tables.each {|table|ActiveRecord::Base.connection.execute("ALTER TABLE `#{table}` CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin\;")}
      puts "Successfully converting database collation to utf8_bin"
    end

  end