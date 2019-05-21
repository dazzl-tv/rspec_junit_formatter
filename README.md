# RSpec JUnit Formatter | [![Build Status](https://travis-ci.org/dazzl-tv/rspec_junit_formatter.svg?branch=master)](https://travis-ci.org/dazzl-tv/rspec_junit_formatter) [![Gem Version](https://badge.fury.io/rb/rspec_junit_formatter_bitbucket.svg)](https://badge.fury.io/rb/rspec_junit_formatter_bitbucket)

__FORK to project : [sj26](https://github.com/sj26/rspec_junit_formatter)__

Use for pipeline bitbucket. Apply rules : http://reflex.gforge.inria.fr/xunit.html#xunitReport

Rspec 3 (remove rspec 2 compatibility) that your CI (Forked for Bitbucket pipeline).

## Usage

Install the gem:

```sh
gem install rspec_junit_formatter_bitbucket
```

Use it:

```sh
# Use RSpec directly
rspec --format JUnit --out ./tmp/test-reports/rspec/report.xml

# use with bundle
export SPEC_OPTS=" --require rspec_junit_formatter_bitbucket --format RspecJunitFormatterBitbucket::Init --out ./tmp/test-reports/rspec/report.xml"
bundle exec rake spec
```

You'll get an XML file `report.xml` with your results in it.

You can use it in combination with other [formatters][rspec-formatters], too:

```sh
rspec --format progress --format RspecJunitFormatterBitbucket::Init --out rspec.xml
```

  [rspec-formatters]: https://relishapp.com/rspec/rspec-core/v/3-8/docs/formatters/custom-formatters

### Using in your project with Bundler

Add it to your Gemfile if you're using [Bundler][bundler]. Put it in the same groups as rspec.

```ruby
group :test do
  gem "rspec"
  gem "rspec_junit_formatter_bitbucket"
end
```

Put the same arguments as the commands above in [your `.rspec`][rspec-file]:

```sh
--format RspecJunitFormatterBitbucket::Init
--out rspec.xml
```
  [bundler]: https://bundler.io
  [rspec-file]: https://relishapp.com/rspec/rspec-core/v/3-6/docs/configuration/read-command-line-configuration-options-from-files

### Parallel tests

For use with `parallel_tests`, add `$TEST_ENV_NUMBER` in the output file option (in `.rspec` or `.rspec_parallel`) to avoid concurrent process write conflicts.

```sh
--format RspecJunitFormatter
--out tmp/rspec<%= ENV["TEST_ENV_NUMBER"] %>.xml
```

The formatter includes `$TEST_ENV_NUMBER` in the test suite name within the XML, too.

### Capturing output

If you like, you can capture the standard output and error streams of each test into the `:stdout` and `:stderr` example metadata which will be added to the junit report, e.g.:

```ruby
# spec_helper.rb

RSpec.configure do |config|
  # register around filter that captures stdout and stderr
  config.around(:each) do |example|
    $stdout = StringIO.new
    $stderr = StringIO.new

    example.run

    example.metadata[:stdout] = $stdout.string
    example.metadata[:stderr] = $stderr.string

    $stdout = STDOUT
    $stderr = STDERR
  end
end
```

## Caveats

 * XML can only represent a [limited subset of characters][xml-charsets] which excludes null bytes and most control characters. This gem will use character entities where possible and fall back to replacing invalid characters with Ruby-like escape codes otherwise. For example, the null byte becomes `\0`.

  [xml-charsets]: https://www.w3.org/TR/xml/#charsets

## Development

Run the specs with `bundle exec rake`, which uses [Appraisal][appraisal] to run the specs against all supported versions of rspec.

  [appraisal]: https://github.com/thoughtbot/appraisal

## License

The MIT License, see [LICENSE](./LICENSE).

## Thanks

And thanks [sj26](https://github.com/sj26)
