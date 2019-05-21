# frozen_string_literal: true

require 'rspec_helper'

describe RspecJunitFormatterBitbucket do
  let(:output) { execute_example_spec }
  let(:doc) { Nokogiri::XML::Document.parse(output) }
  let(:testsuite) { doc.xpath('/test-suite').first }
  let(:testcases) { doc.xpath('/test-suite/test-case') }
  let(:successful_testcases) { doc.xpath('/test-suite/test-case[not(failure) and not(skipped)]') }
  let(:pending_testcases) { doc.xpath('/test-suite/test-case[skipped]') }
  let(:failed_testcases) { doc.xpath('/test-suite/test-case[failure]') }
  let(:shared_testcases) { doc.xpath("/test-suite/test-case[contains(@name, 'shared example')]") }
  let(:failed_shared_testcases) { doc.xpath("/test-suite/test-case[contains(@name, 'shared example')][failure]") }
  let(:diff_testcase_failure) { doc.xpath("//test-case[contains(@name, 'diffs')]/failure").first }

  it 'with test-case attribute' do
    expect(testcases.size).to be(12)
  end

  shared_examples 'testcase eql' do |attr, result|
    it "with test-case attribute #{attr}" do
      expect(testcases.first[attr]).to eql(result)
    end
  end

  shared_examples 'testcase >' do |attr, result|
    it "with test-case attribute #{attr}" do
      expect(testcases.first[attr]).to be > result
    end
  end

  it_behaves_like 'testcase eql', 'classname', 'spec.example_spec'
  it_behaves_like 'testcase eql', 'file', './spec/example_spec.rb'
  # it_behaves_like 'testcase >', 'line_number', '0'
  # expect(testcase["line_number"].to_i).to be > 0
  it_behaves_like 'testcase eql', 'name', 'JUnit example specs raises'
  it_behaves_like 'testcase >', 'time', '0'

  it 'with test-case successful has size' do
    expect(successful_testcases.size).to be(3)
  end

  it 'with test-case successful' do
    successful_testcases.first do |testcase|
      expect(testcase).not_to be(nil)
    end
  end

  it 'with test-case sucessful children name' do
    successful_testcases.first do |testcase|
      unless (testcase['name']) =~ /capture stdout and stderr/
        expect(testcase.children).to be_empty
      end
    end
  end

  it 'with test-case pending children size' do
    pending_testcases.first do |testcase|
      expect(testcase.element_children.size).to be(1)
    end
  end

  it 'with test-case pending child name' do
    pending_testcases.first do |testcase|
      child = testcase.element_children.first
      expect(child.name).to eql('skipped')
    end
  end

  it 'with test-case pending child attributes' do
    pending_testcases.first do |testcase|
      child = testcase.element_children.first
      expect(child.attributes).to be_empty
    end
  end

  it 'with test-case pending child text' do
    pending_testcases.first do |testcase|
      child = testcase.element_children.first
      expect(child.text).to be_empty
    end
  end

  it 'with test-case failed has size' do
    expect(failed_testcases.size).to be(8)
  end

  it 'with test-case failed children size' do
    failed_testcases.first do |testcase|
      expect(testcase.element_children.size).to be(1)
    end
  end

  it 'with test-case failed child file' do
    failed_testcases.first do |testcase|
      expect(testcase['file']).not_to be_empty
    end
  end

  it 'with test-case failed line_number' do
    failed_testcases.first do |testcase|
      expect(testcase['line_number'].to_i).to be > 0
    end
  end

  it 'with test-case failed child name' do
    failed_testcases.first do |testcase|
      child = testcase.element_children.first
      expect(child.name).to eql('failure')
    end
  end

  it 'with test-case failed child message' do
    failed_testcases.first do |testcase|
      child = testcase.element_children.first
      expect(child['message']).not_to be_empty
    end
  end

  it 'with test-case failed child strip not empty' do
    failed_testcases.first do |testcase|
      child = testcase.element_children.first
      expect(child.text.strip).not_to be_empty
    end
  end

  it 'with test-case failed child strip match to reex' do
    failed_testcases.first do |testcase|
      child = testcase.element_children.first
      expect(child.text.strip).not_to match(/\\e\[(?:\d+;?)+m/)
    end
  end

  it 'with test-case shared' do
    expect(shared_testcases.size).to be(2)
  end

  it 'with test-case shared has classname' do
    shared_testcases.first do |testcase|
      # shared examples should be groups with their including files
      expect(testcase['classname']).to eql('spec.example_spec')
    end
  end

  it 'with test-case failed shared' do
    expect(failed_shared_testcases.size).to be(1)
  end

  it 'with test-case failed shared include example' do
    failed_shared_testcases.each do |testcase|
      expect(testcase.text).to include('example_spec.rb')
    end
  end

  it 'with test-case failed shared include shared example' do
    failed_shared_testcases.each do |testcase|
      expect(testcase.text).to include('shared_examples.rb')
    end
  end

  it 'with test-case diff message' do
    # it cleans up diffs
    expect(diff_testcase_failure[:message]).not_to match(/\e | \\e/x)
  end

  it 'with test-case diff text' do
    expect(diff_testcase_failure.text).not_to match(/\e | \\e/x)
  end

  it 'with test-case correctly replaces illegal characters' do
    expect(doc.xpath("//test-case[contains(@name, 'naughty')]").first[:name]).to \
      eql('JUnit example specs when \\characters replaces naughty \\0 and \\e characters, \\x01 and \\uFFFF too')
  end

  it 'with test-case correctly escapes discouraged characters' do
    expect(doc.xpath("//test-case[contains(@name, 'controlling')]").first[:name]).to \
      eql('JUnit example specs when pacman character escapes controlling \\u{7f} characters')
  end

  it 'with test-case correctly escapes emoji characters' do
    expect(doc.xpath("//test-case[contains(@name, 'unicodes')]").first[:name]).to \
      eql('JUnit example specs when unicode character can include unicodes 😁')
  end

  it 'with test-case correctly escapes reserved xml characters' do
    expect(doc.xpath("//test-case[contains(@name, 'html')]").first[:name]).to \
      eql(%(JUnit example specs when HTML character escapes <html tags='correctly' and='such &amp; such'>))
  end

  it 'with test-case correctly captures stdout output' do
    expect(doc.xpath('//test-case/system-out').text).to eql("Test\n")
  end

  it 'with test-case correctly captures stderr output' do
    expect(doc.xpath('//test-case/system-err').text).to eql("Bar\n")
  end
end
