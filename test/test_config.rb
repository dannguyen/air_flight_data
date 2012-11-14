require 'factory_girl'
require 'database_cleaner'

PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path('../../config/boot', __FILE__)

require_relative 'factories'


class MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    ##
    # You can handle all padrino applications using instead:
    #   Padrino.application
    SkiftAir.tap { |app|  }
  end
end
