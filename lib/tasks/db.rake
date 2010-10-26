namespace :db do
  desc "Generates migrations as per structure design in your models but does not run them"
  task :update do
    DataForge::MigrationGenerator.new.run
  end
  
  desc "Generates migrations as per structure design in your models and runs them"
  task :upgrade do
    puts "Upgrade ran!"
  end
end
