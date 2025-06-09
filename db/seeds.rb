# Load environment-specific seed files
# This allows different seed data for development, production, etc.

puts "Loading #{Rails.env} seeds..."

# Load base seeds (common across all environments)
load Rails.root.join('db', 'seeds', 'base.rb') if File.exist?(Rails.root.join('db', 'seeds', 'base.rb'))

# Load environment-specific seeds
environment_seeds = Rails.root.join('db', 'seeds', "#{Rails.env}.rb")
load environment_seeds if File.exist?(environment_seeds)

puts "Seeds loaded successfully for #{Rails.env} environment"
