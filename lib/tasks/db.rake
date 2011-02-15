namespace :db do
  desc "Generates migrations as per structure design in your models and runs them"
  task :upgrade => :environment do
    if Migrant::MigrationGenerator.new.run
      puts "\nInvoking db:migrate for #{Rails.env} environment."
      Rake::Task['db:migrate'].invoke

      # If RAILS_ENV is explicitly specified, don't clone out to test
      unless ENV['RAILS_ENV']
        puts "Migrated. Now, cloning out to the test database."
        Rake::Task['db:test:clone'].invoke
      end
    end
  end
end

