# frozen_string_literal: true

require 'rspec_helper'

describe RspecJunitFormatterBitbucket do
  let(:output) { execute_example_spec }
  let(:doc) { Nokogiri::XML::Document.parse(output) }
  let(:testsuite) { doc.xpath('/test-suite').first }

  it 'with test-suite attribute' do
    expect(testsuite).not_to be(nil)
  end

  it 'with test-suite has attribute name' do
    expect(testsuite['name']).to eql('rspec')
  end

  it 'with test-suite has attribute tests' do
    expect(testsuite['tests']).to eql('12')
  end

  it 'with test-suite has attribute skipped' do
    expect(testsuite['skipped']).to eql('1')
  end

  it 'with test-suite has attribute failures' do
    expect(testsuite['failures']).to eql('8')
  end

  it 'with test-suite has attribute errors' do
    expect(testsuite['errors']).to eql('0')
  end

  it 'with test-suite has attribute timestamp' do
    expect(Time.parse(testsuite['timestamp'])).to be_within(60).of(Time.now)
  end

  it 'with test-suite has attribute time' do
    expect(testsuite['time'].to_f).to be > 0
  end

  it 'with test-suite has attribute hostname' do
    expect(testsuite['hostname']).not_to be_empty
  end
end
