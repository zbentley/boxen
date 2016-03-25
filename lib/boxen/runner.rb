require "boxen/config"
require "boxen/hook"
require "boxen/flags"
require "boxen/puppeteer"
require "boxen/util"
require "facter"

module Boxen
  class Runner
    attr_reader :config
    attr_reader :flags
    attr_reader :puppet
    attr_reader :checkout
    attr_reader :hooks

    def initialize(config, flags)
      @config   = config
      @flags    = flags
      @puppet   = Boxen::Puppeteer.new(@config)
      @hooks    = Boxen::Hook.all
    end

    def process
      # --env prints out the current BOXEN_ env vars.

      exec "env | grep ^BOXEN_ | sort" if flags.env?

      # Actually run Puppet and return its result

      puppet.run
    end

    def run
      report(process)
    end

    def report(result)
      hooks.each { |hook| hook.new(config, checkout, puppet, result).run }

      result
    end

  end
end
