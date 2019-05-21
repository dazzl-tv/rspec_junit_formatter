# frozen_string_literal: true

require 'pty'
require 'nokogiri'
require 'rspec_junit_formatter_bitbucket'

def execute_example_spec
  formatter_arguments = ['--require', 'rspec_junit_formatter_bitbucket', '--format', 'JUnit']
  color_opt = RSpec.configuration.respond_to?(:color_mode=) ? '--force-color' : '--color'
  extra_arguments = []
  command = ['bundle', 'exec', 'rspec', *formatter_arguments, color_opt, *extra_arguments]

  safe_pty(command, File.expand_path('../example', __dir__))
end

def pty_read(read, pid)
  read.each_line { |line| sio.puts(line) }
rescue Errno::EIO => e
  warn "[ERROR] Errno::EIO : #{e}"
ensure
  ::Process.wait pid
end

# rubocop:disable Metrics/MethodLength, Style/RedundantBegin
def safe_pty(command, directory)
  sio = StringIO.new
  begin
    PTY.spawn(*command, chdir: directory) do |read, _, pid|
      begin
        read.each_line { |line| sio.puts(line) }
      rescue Errno::EIO => e
        warn "[ERROR] Errno::EIO : #{e}"
      ensure
        ::Process.wait pid
      end
    end
  rescue PTY::ChildExited => e
    warn "[ERROR] PTY::ChildExited : #{e}"
  end
  sio.string
end
# rubocop:enable Metrics/MethodLength, Style/RedundantBegin
