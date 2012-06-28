require "active_record"
require "ferrety"
require "stock_ferret"
require "weather_ferret"
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
  class Alert < ActiveRecord::Base
    belongs_to :instruction
    validate :not_old_news, on: :create

    def not_old_news
      errors[:base] << "This is old news." if old_news?
    end

    def old_news?
      Alert.where("instruction_id = ? and report_id is not null", instruction.id).any?
    end
  end

  class Instruction < ActiveRecord::Base
    has_many :alerts
    @queue = :ferret_queue

    def self.runnable
      where("last_run < ?", DateTime.now - 4.hours)
    end

    def self.perform(id)
      find(id).perform
    end

    def perform
      connect_to_database
      update_attribute(:last_run, DateTime.now)
      ferret.search.each do |alert_body|
        alerts.create(body: alert_body, user_id: user_id, report_id: id)
      end
    end

    def connect_to_database
      ActiveRecord::Base.establish_connection(
        :adapter => 'mysql2',
        :database =>  DATABASE_NAME,
        :username => "root",
        :password => MYSQL_PASSWORD,
        :host => "localhost")
    end

    def ferret_class
      ("Ferrety::" + ferret_type).classify.constantize
    end

    def ferret
      ferret_class.new(params)
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
      instructions = Instruction.runnable
      instructions.each do |instruction|
        Resque.enqueue(Instruction, instruction.id)
      end
    end

  end
end

scheduler = Ferrety::Scheduler.new.call









