# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

# Formatter for RSpec
# Write an file xml for reporting errors.
class JUnit < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register self,
                                   :start,
                                   :stop,
                                   :dump_summary

  attr_reader :started

  def initialize(output)
    @output = output
  end

  def start(notification)
    @start_notification = notification
    @started = Time.now
    super
  end

  def stop(notification)
    @examples_notification = notification
  end

  def dump_summary(notification)
    @summary_notification = notification
    xml = RspecJunitFormatterBitbucket::XML.new(@output, self)

    without_color do
      xml.dump
    end
  end

  # private

  def example_count
    @summary_notification.example_count
  end

  def pending_count
    @summary_notification.pending_count
  end

  def failure_count
    @summary_notification.failure_count
  end

  def duration
    @summary_notification.duration
  end

  def examples
    @examples_notification.notifications
  end

  def result_of(notification)
    notification.example.execution_result.status
  end

  def failure_type_for(example)
    exception_for(example).class.name
  end

  def failure_message_for(example)
    exception = exception_for(example).to_s
    RspecJunitFormatterBitbucket::Format.strip_diff_colors(exception)
  end

  def failure_for(notification)
    exception = notification.message_lines.join("\n")
    RspecJunitFormatterBitbucket::Format.strip_diff_colors(exception) << \
      "\n" << notification.formatted_backtrace.join("\n")
  end

  def exception_for(notification)
    notification.example.execution_result.exception
  end

  # rspec makes it really difficult to swap in configuration temporarily due to
  # the way it cascades defaults, command line arguments, and user
  # configuration. This method makes sure configuration gets swapped in
  # correctly, but also that the original state is definitely restored.
  def swap_rspec_configuration(key, value)
    unset = Object.new
    force = RSpec.configuration.send(:value_for, key) { unset }
    previous = check_swap(key, value, force, unset)
    yield
  ensure
    ensure_swap(key, force, previous, unset)
  end

  def check_swap(key, value, force, unset)
    if unset.equal?(force)
      previous = RSpec.configuration.send(key)
      RSpec.configuration.send(:"#{key}=", value)
    else
      RSpec.configuration.force(key => value)
    end
    previous
  end

  def ensure_swap(key, force, previous, unset)
    if unset.equal?(force)
      RSpec.configuration.send(:"#{key}=", previous)
    else
      RSpec.configuration.force(key => force)
    end
  end

  # Completely gross hack for absolutely forcing off colorising for the
  # duration of a block.
  if RSpec.configuration.respond_to?(:color_mode=)
    def without_color(&block)
      swap_rspec_configuration(:color_mode, :off, &block)
    end
  elsif RSpec.configuration.respond_to?(:color=)
    def without_color(&block)
      swap_rspec_configuration(:color, false, &block)
    end
  else
    warn 'rspec_junit_formatter cannot prevent colorising due ' \
         'to an unexpected RSpec.configuration format'
    def without_color
      yield
    end
  end

  def stdout_for(example_notification)
    example_notification.example.metadata[:stdout]
  end

  def stderr_for(example_notification)
    example_notification.example.metadata[:stderr]
  end
end
# rubocop:enable Metrics/ClassLength
