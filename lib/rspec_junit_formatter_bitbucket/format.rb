# frozen_string_literal: false

module RspecJunitFormatterBitbucket
  # Make sure it's utf-8, replace illegal characters with
  # ruby-like escapes, and replace special and discouraged
  # characters with entities
  module Format
    # Inversion of character range from https://www.w3.org/TR/xml/#charsets
    ILLEGAL_REGEXP = Regexp.new(
      '\[\^' \
      '\u{9}' \
      '\u{a}' \
      '\u{d}' \
      '\u{20}-\u{d7ff}' \
      '\u{e000}-\u{fffd}' \
      '\u{10000}-\u{10ffff}' \
      '\]'
    )

    # Replace illegals with a Ruby-like escape
    ILLEGAL_REPLACEMENT = Hash.new do |_, c|
      x = c.ord
      if x <= 0xff
        '\\x%02X'.freeze % x
      elsif x <= 0xffff
        '\\u%04X'.freeze % x
      else
        '\\u{%<X>}'.freeze % x
      end.freeze
    end.update(
      "\0".freeze => '\\0'.freeze,
      "\a".freeze => '\\a'.freeze,
      "\b".freeze => '\\b'.freeze,
      "\f".freeze => '\\f'.freeze,
      "\v".freeze => '\\v'.freeze,
      "\e".freeze => '\\e'.freeze
    ).freeze

    # Discouraged characters from https://www.w3.org/TR/xml/#charsets
    # Plus special characters with well-known entity replacements
    DISCOURAGED_REGEXP = Regexp.new(
      '[' \
      '\u{22}' \
      '\u{26}' \
      '\u{27}' \
      '\u{3c}' \
      '\u{3e}' \
      '\u{7f}-\u{84}' \
      '\u{86}-\u{9f}' \
      '\u{fdd0}-\u{fdef}' \
      '\u{1fffe}-\u{1ffff}' \
      '\u{2fffe}-\u{2ffff}' \
      '\u{3fffe}-\u{3ffff}' \
      '\u{4fffe}-\u{4ffff}' \
      '\u{5fffe}-\u{5ffff}' \
      '\u{6fffe}-\u{6ffff}' \
      '\u{7fffe}-\u{7ffff}' \
      '\u{8fffe}-\u{8ffff}' \
      '\u{9fffe}-\u{9ffff}' \
      '\u{afffe}-\u{affff}' \
      '\u{bfffe}-\u{bffff}' \
      '\u{cfffe}-\u{cffff}' \
      '\u{dfffe}-\u{dffff}' \
      '\u{efffe}-\u{effff}' \
      '\u{ffffe}-\u{fffff}' \
      '\u{10fffe}-\u{10ffff}' \
      ']'
    )

    # Translate well-known entities, or use generic unicode hex entity
    DISCOURAGED_REPLACEMENTS = Hash.new do |_, c|
      "&#x#{c.ord.to_s(16)};".freeze
    end.update(
      '"'.freeze => '&quot;'.freeze,
      '&'.freeze => '&amp;'.freeze,
      "'".freeze => '&apos;'.freeze,
      '<'.freeze => '&lt;'.freeze,
      '>'.freeze => '&gt;'.freeze
    ).freeze

    def self.escape(text)
      text.to_s
          .encode(Encoding::UTF_8)
          .gsub(ILLEGAL_REGEXP, ILLEGAL_REPLACEMENT)
          .gsub(DISCOURAGED_REGEXP, DISCOURAGED_REPLACEMENTS)
    end

    # rubocop:disable Metrics/LineLength
    STRIP_DIFF_COLORS_BLOCK_REGEXP = /^ ( [ ]* ) Diff: (?: \e\[ 0 m )? (?: \n \1 \e\[ \d+ (?: ; \d+ )* m .* )* /x.freeze
    # rubocop:enable Metrics/LineLength
    STRIP_DIFF_COLORS_CODES_REGEXP = /\e\[ \d+ (?: ; \d+ )* m/x.freeze

    def self.strip_diff_colors(string)
      # XXX: RSpec diffs are appended to the message lines fairly early and will
      # contain ANSI escape codes for colorizing terminal output if the global
      # rspec configuration is turned on, regardless of which notification lines
      # we ask for. We need to strip the codes from the diff part of the message
      # for XML output here.
      #
      # We also only want to target the diff hunks because the failure message
      # itself might legitimately contain ansi escape codes.
      #
      string.sub(STRIP_DIFF_COLORS_BLOCK_REGEXP) do |match|
        match.gsub(STRIP_DIFF_COLORS_CODES_REGEXP, ''.freeze)
      end
    end
  end
end
