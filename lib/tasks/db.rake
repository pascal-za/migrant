namespace :db do
  desc "Generates migrations from schema.rb configuration. Does not run the migrations."
  task :update do
    puts "Task ran!"
  end
  
  desc "Generates migrations from schema.rb and migrates database"
end
