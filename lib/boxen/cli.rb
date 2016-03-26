require "boxen/config"
require "boxen/flags"
require "boxen/util"
require "boxen/puppeteer"

module Boxen
  class CLI
    attr_reader :config
    attr_reader :flags

    def initialize(config, flags)
      @config = config
      @flags  = flags
      @puppet = Boxen::Puppeteer.new(@config)
    end

    def run
      if flags.help?
        puts flags
        exit
      end
      Boxen::Util.sudo("/bin/mkdir", "-p", config.homedir) &&
        Boxen::Util.sudo("/usr/sbin/chown", "#{config.user}:staff", config.homedir)
      @puppet.run
    end

    # Run Boxen by wiring together the command-line flags, config,
    # preflights, Puppet execution, and postflights. Returns Puppet's
    # exit code.

    def self.run(*args)
      config = Boxen::Config.load
      flags  = Boxen::Flags.new args

      # Apply command-line flags to the config in case we're changing or
      # overriding anything.
      flags.apply config

      if flags.run?
        # Save the config for Puppet (and next time).
        Boxen::Config.save config
      end

      # Make the magic happen.
      status = Boxen::CLI.new(config, flags).run

      # Return Puppet's exit status.
      return status.code
    end
  end
end
