require "active_record"
require "resque"

if ENV["RAILS_ENV"] == "production"
  DATABASE_NAME = "ferrety_production"
  MYSQL_PASSWORD = "databucket2"
elsif ENV["RAILS_ENV"] == "test"
  DATABASE_NAME = "ferrety_test"
  MYSQL_PASSWORD = ""
else
  DATABASE_NAME = "ferrety_development"
  MYSQL_PASSWORD = ""
end


module Ferrety

  class Instruction < ActiveRecord::Base
    @queue = :ferret_queue
    def self.runnable
      where("last_run < ?", DateTime.now - 4.hours)
    end
  end

  class Scheduler

    def initialize
      ActiveRecord::Base.establish_connection(
        :adapter => 'mysql2',
        :database =>  DATABASE_NAME,
        :username => "root",
        :password => MYSQL_PASSWORD,
        :host => "localhost")
    end

    def call
      instructions = Instruction.all
      instructions.each do |instruction|
        Resque.enqueue(Instruction, instruction.to_json)
      end
    end

  end
end

scheduler = Ferrety::Scheduler.new.call









