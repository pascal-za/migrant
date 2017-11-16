namespace :db do
  desc "Generates migrations as per structure design in your models and runs them"
  task :upgrade => :environment do
    if Migrant::MigrationGenerator.new.run
      puts "\nInvoking db:migrate for #{Rails.env} environment."
      Rake::Task['db:migrate'].invoke
    end
  end
  
  desc "Provides a shortcut to rolling back and discarding the last migration"
  task :downgrade => :environment do
    Rake::Task['db:rollback'].invoke
    Dir.chdir(Rails.root.join('db', 'migrate')) do
      last_migration = Dir.glob('*.rb').sort.last and
      File.unlink(last_migration) and
      puts "Removed #{Dir.pwd}/#{last_migration}."      
    end
  
    Rake::Task['db:test:clone'].invoke unless ENV['RAILS_ENV']
  end
end

