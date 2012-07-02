require 'httparty'
require 'json'
require "resque"

INTERNAL_PASSWORD = '350c9d803c149399e61641e1e81228464f94e02351afb18da921096f7d6e9caee1722560db2000e73851699c8fd8d869d604ec91d49b6982483cc6960a5a4d82'
INSTRUCTION_ENDPOINT = 'http://ferrety.net/instructions/runnable.json'

module Ferrety

  class Instruction
    @queue = :ferret_queue
    def self.runnable
      response = HTTParty.get(URI.parse("#{INSTRUCTION_ENDPOINT}?pw=#{INTERNAL_PASSWORD}"))
      puts response.inspect
    end
  end

  class Scheduler

    def call
      instructions = Instruction.runnable
      instructions.each do |instruction|
        Resque.enqueue(Instruction, instruction.to_json)
      end
    end

  end
end

scheduler = Ferrety::Scheduler.new.call