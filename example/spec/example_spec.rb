# frozen_string_literal: true

require 'spec_helper'
require_relative 'shared_examples'

describe 'JUnit example specs' do
  context 'when success' do
    let(:base) { true }
    let(:output) { true }

    it 'succeeds' do
      expect(base).to be(output)
    end
  end

  context 'when failed' do
    let(:base) { false }
    let(:output) { true }

    it 'fails' do
      expect(base).to be(output)
    end
  end

  it 'raises' do
    raise ArgumentError
  end

  it 'is pending' do
    if defined? skip
      skip
    else
      pending
    end
  end

  context 'when diff' do
    let(:base) { { a: 'b', c: 'd' } }
    let(:output) { { a: 2, c: 4 } }

    it 'shows diffs cleanly' do
      expect(base).to eql(output)
    end
  end

  context 'when \characters' do
    let(:base) { '\0\0\0' }
    let(:output) { 'emergency services' }

    it 'replaces naughty \0 and \e characters, \x01 and \uFFFF too' do
      expect(base).to eql(output)
    end
  end

  context 'when pacman character' do
    let(:base) { '\u{7f}' }
    let(:output) { 'pacman om nom nom' }

    it 'escapes controlling \u{7f} characters' do
      expect(base).to eql(output)
    end
  end

  context 'when unicode character' do
    let(:base) { '🚀' }
    let(:output) { '🔥' }

    it 'can include unicodes 😁' do
      expect(base).to eql(output)
    end
  end

  context 'when HTML character' do
    let(:base) { '<p>This is important</p>' }
    let(:output) { '<p>This is <strong>very</strong> important</p>' }

    it %(escapes <html tags='correctly' and='such &amp; such'>) do
      expect(base).to eql(output)
    end
  end

  it_behaves_like 'shared examples'

  it 'can capture stdout and stderr' do
    $stdout.puts 'Test'
    warn 'Bar'
  end
end
