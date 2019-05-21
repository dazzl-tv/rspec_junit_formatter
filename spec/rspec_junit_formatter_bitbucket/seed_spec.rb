# frozen_string_literal: true

require 'rspec_helper'

describe RspecJunitFormatterBitbucket do
  let(:output) { execute_example_spec }
  let(:doc) { Nokogiri::XML::Document.parse(output) }
  let(:extra_arguments) { ['--seed', '12345'] }
  let(:seed_property) { doc.xpath("/test-suite/properties/property[@name='seed']").first }

  it 'with seed property name' do
    expect(seed_property['name']).to eql('seed')
  end

  it 'with seed property value' do
    expect(seed_property['value'].to_i).to be_a(Integer)
  end
end
