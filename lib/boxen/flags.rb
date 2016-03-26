require "optparse"

module Boxen

  # Various flags and settings parsed from the command line. See
  # Setup::Configuration for more info.

  class Flags

    attr_reader :args
    attr_reader :homedir
    attr_reader :logfile
    attr_reader :login
    attr_reader :srcdir
    attr_reader :user

    attr_reader :disable_service
    attr_reader :enable_service
    attr_reader :restart_service

    # Create a new instance, optionally providing CLI `args` to
    # parse immediately.

    def initialize(*args)
      @args             = []
      @debug            = false
      @env              = false
      @fde              = true
      @help             = false
      @pretend          = false
      @report           = false
      @graph            = false
      @color            = true

      @options = OptionParser.new do |o|
        o.banner = "Usage: #{File.basename $0} [options] [projects...]\n\n"

        o.on "--debug", "Be really verbose." do
          @debug = true
        end

        o.on "--noop", "Don't make changes." do
          @pretend = true
        end

        o.on "--report", "Enable puppet reports." do
          @report = true
        end

        o.on "--graph", "Enable generation of dependency graphs." do
          @graph = true
        end

        o.on "--env", "Show useful environment variables." do
          @env = true
        end

        o.on "--help", "-h", "-?", "Show help." do
          @help = true
        end

        o.on "--homedir DIR", "Boxen's home directory." do |homedir|
          @homedir = homedir
        end

        o.on "--no-fde", "Don't require full disk encryption." do
          @fde = false
        end

        o.on "--future-parser", "Enable the Puppet future parser" do
          @future_parser = true
        end

        o.on "--user USER", "Your local user." do |user|
          @user = user
        end

        o.on "--no-color", "Disable colors." do
          @color = false
        end
      end

      parse args.flatten.compact
    end

    # Apply these flags to `config`. Returns `config`.

    def apply(config)
      config.debug         = debug?
      config.fde           = fde?     if config.fde?
      config.homedir       = homedir  if homedir
      config.logfile       = logfile  if logfile
      config.pretend       = pretend?
      config.future_parser = future_parser?
      config.report        = report?
      config.graph         = graph?
      config.user          = user     if user
      config.color         = color?

      config
    end

    def debug?
      @debug
    end

    def env?
      @env
    end

    def fde?
      @fde
    end

    def help?
      @help
    end

    def run?
      ! help?
    end

    # Parse `args` as an array of CLI argument Strings. Raises
    # Boxen::Error if anything goes wrong. Returns `self`.

    def parse(*args)
      @args = @options.parse! args.flatten.compact.map(&:to_s)

      self

    rescue OptionParser::MissingArgument, OptionParser::InvalidOption => e
      raise Error, "#{e.message}\n#@options"
    end

    def pretend?
      @pretend
    end

    def future_parser?
      @future_parser
    end

    def report?
      @report
    end

    def graph?
      @graph
    end

    def color?
      @color
    end

    def to_s
      @options.to_s
    end
  end
end
