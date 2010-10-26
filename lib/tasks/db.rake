namespace :db do
  desc "Generates migrations as per structure design in your models but does not run them"
  task :update => :environment do
    DataForge::MigrationGenerator.new.run
  end
  
  desc "Generates migrations as per structure design in your models and runs them"
  task :upgrade => :environment do
    DataForge::MigrationGenerator.new.run
    Rake::Task['db:migrate'].invoke
  end
end
