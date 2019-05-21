# frozen_string_literal: true

require 'rspec_helper'

describe RspecJunitFormatterBitbucket do
  context 'when $TEST_ENV_NUMBER is set' do
    around do |example|
      ENV['TEST_ENV_NUMBER'] = '42'
      example.call
    ensure
      ENV.delete('TEST_ENV_NUMBER')
    end

    let(:output) { execute_example_spec }
    let(:doc) { Nokogiri::XML::Document.parse(output) }
    let(:testsuite) { doc.xpath('/test-suite').first }

    it 'includes $TEST_ENV_NUMBER in the testsuite name' do
      expect(testsuite['name']).to eql('rspec42')
    end
  end
end
