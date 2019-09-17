require 'grape'

Dir["#{File.dirname(__FILE__)}/app/api/*.rb"].each { |f| require f }
