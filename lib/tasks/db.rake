namespace :db do
  desc "Generates migrations as per structure design in your models and runs them"
  task :upgrade => :environment do
    Rake::Task['db:migrate'].invoke if Migrant::MigrationGenerator.new.run
  end
end
