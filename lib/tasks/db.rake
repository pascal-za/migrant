namespace :db do
  desc "Generates migrations from schema.rb configuration. Does not run the migrations."
  task :update do
    puts "Update ran!"
  end
  
  desc "Generates migrations from schema.rb and migrates database"
  task :upgrade do
    puts "Upgrade ran!"
  end
end
