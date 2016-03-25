require "fileutils"
require "json"
require "shellwords"

module Boxen

  # All configuration for Boxen, whether it's loaded from command-line
  # args, environment variables, config files, or the keychain.

  class Config
    def self.load(&block)
      new do |config|
        file = "#{config.homedir}/config/boxen/defaults.json"

        if File.file? file
          attrs = JSON.parse File.read file

          attrs.each do |key, value|
            if !value.nil? && config.respond_to?(selector = "#{key}=")
              config.send selector, value
            end
          end
        end

        yield config if block_given?
      end
    end

    # Save `config`. Returns `config`. Note that this only saves data,
    # not flags. For example, `login` will be saved, but `stealth?`
    # won't.

    def self.save(config)
      attrs = {
        :email        => config.email,
        :fde          => config.fde?,
        :homedir      => config.homedir,
        :login        => config.login,
        :name         => config.name,
        :puppetdir    => config.puppetdir,
        :user         => config.user,
      }

      file = "#{config.homedir}/config/boxen/defaults.json"
      FileUtils.mkdir_p File.dirname file

      File.open file, "wb" do |f|
        f.write JSON.generate Hash[attrs.reject { |k, v| v.nil? }]
      end

      config
    end

    # Create a new instance. Yields `self` if `block` is given.

    def initialize(&block)
      @fde  = true
      @pull = true

      yield self if block_given?
    end

    # Spew a bunch of debug logging? Default is `false`.

    def debug?
      !!@debug
    end

    attr_writer :debug

    # A GitHub user's public email.

    attr_accessor :email

    # The shell script that loads Boxen's environment.

    def envfile
      "#{homedir}/env.sh"
    end

    # Is full disk encryption required? Default is `true`. Respects
    # the `BOXEN_NO_FDE` environment variable.

    def fde?
      !ENV["BOXEN_NO_FDE"] && @fde
    end

    attr_writer :fde

    # Boxen's home directory. Default is `"/opt/boxen"`. Respects the
    # `BOXEN_HOME` environment variable.

    def homedir
      @homedir || ENV["BOXEN_HOME"] || "/opt/boxen"
    end

    attr_writer :homedir

    # Boxen's log file. Default is `"#{repodir}/log/boxen.log"`.
    # Respects the `BOXEN_LOG_FILE` environment variable. The log is
    # overwritten on every run.

    def logfile
      @logfile || ENV["BOXEN_LOG_FILE"] || "#{repodir}/log/boxen.log"
    end

    attr_writer :logfile

    # A GitHub user login. Default is `nil`.

    attr_accessor :login

    # A GitHub user's profile name.

    attr_accessor :name

    # Just go through the motions? Default is `false`.

    def pretend?
      !!@pretend
    end

    attr_writer :pretend

    # Run a profiler on Puppet? Default is `false`.

    def profile?
      !!@profile
    end

    attr_writer :profile

    # Enable the Puppet future parser? Default is `false`.

    def future_parser?
      !!@future_parser
    end

    attr_writer :future_parser

    # Enable puppet reports ? Default is `false`.

    def report?
      !!@report
    end

    attr_writer :report

    # Enable generation of dependency graphs.

    def graph?
      !!@graph
    end

    attr_writer :graph

    # The directory where Puppet expects configuration (which we don't
    # use) and runtime information (which we generally don't care
    # about). Default is `/tmp/boxen/puppet`. Respects the
    # `BOXEN_PUPPET_DIR` environment variable.

    def puppetdir
      @puppetdir || ENV["BOXEN_PUPPET_DIR"] || "/tmp/boxen/puppet"
    end

    attr_writer :puppetdir

    # The directory of the custom Boxen repo for an org. Default is
    # `Dir.pwd`. Respects the `BOXEN_REPO_DIR` environment variable.

    def repodir
      @repodir || ENV["BOXEN_REPO_DIR"] || Dir.pwd
    end

    attr_writer :repodir


    # A local user login. Default is the `USER` environment variable.

    def user
      @user || ENV["USER"]
    end

    attr_writer :user

    def color?
      @color
    end

    attr_writer :color

  end
end
