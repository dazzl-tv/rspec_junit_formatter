# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
module RspecJunitFormatterBitbucket
  # Write XML file
  class XML
    def initialize(output, example)
      @test = example
      @output = output
      @output << first_node
    end

    def dump
      @output << %(<test-suite #{testsuite_attr} >\n)
      @output << %(<properties>\n)
      @output << %(<property)
      @output << %( name="seed")
      @output << %( value="#{Format.escape(RSpec.configuration.seed.to_s)}")
      @output << %(/>\n)
      @output << %(</properties>\n)
      dump_examples
      @output << %(</test-suite>\n)
    end

    private

    def first_node
      %(<?xml version="1.0" encoding="UTF-8"?>\n\n)
    end

    def testsuite_attr
      <<~TESTSUITE
        name="rspec#{Format.escape(ENV['TEST_ENV_NUMBER'].to_s)}"
        tests="#{@test.example_count}"
        skipped="#{@test.pending_count}"
        failures="#{@test.failure_count}"
        errors="0"
        time="#{Format.escape(format('%.6f', @test.duration))}"
        timestamp="#{Format.escape(@test.started.iso8601)}"
        hostname="#{Format.escape(Socket.gethostname)}"
      TESTSUITE
    end

    def dump_examples
      @test.examples.each do |example|
        case @test.result_of(example)
        when :pending
          dump_pending(example)
        when :failed
          dump_failed(example)
        else
          dump_example(example)
        end
      end
    end

    def dump_pending(example)
      dump_example(example) do
        @output << %(<skipped/>)
      end
    end

    def dump_failed(example)
      dump_example(example) do
        @output << %(<failure)
        @output << %( message="#{Format.escape(@test.failure_message_for(example))}")
        @output << %( type="#{Format.escape(@test.failure_type_for(example))}")
        @output << %(>)
        @output << Format.escape(@test.failure_for(example))
        @output << %(</failure>)
      end
    end

    def dump_example(example)
      @output << %(<test-case )
      @output << testcase_attr(example)
      @output << %(>)
      yield if block_given?
      dump_output(example)
      @output << %(</test-case>\n)
    end

    def testcase_attr(example)
      <<~TESTCASE
        classname="#{Format.escape(Attribute.classname_for(example))}"
        name="#{Format.escape(Attribute.description_for(example))}"
        file="#{Format.escape(Attribute.example_group_file_path_for(example))}"
        time="#{Format.escape(format('%.6f', Attribute.duration_for(example)))}"
      TESTCASE
    end

    def dump_output(example)
      stdout = @test.stdout_for(example)
      write_stdout(stdout) unless stdout.empty?

      stderr = @test.stderr_for(example)
      write_stderr(stderr) unless stderr.empty?
    end

    def write_stdout(stdout)
      @output << %(<system-out>)
      @output << Format.escape(stdout)
      @output << %(</system-out>)
    end

    def write_stderr(stderr)
      @output << %(<system-err>)
      @output << Format.escape(stderr)
      @output << %(</system-err>)
    end
  end
end
# rubocop:enable Metrics/LineLength
