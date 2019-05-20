# frozen_string_literal: true

# rubocop:disable Lint/AssignmentInCondition
module RspecJunitFormatterBitbucket
  # Format attribute to xml
  module Attribute
    def self.classname_for(notification)
      fp = example_group_file_path_for(notification)
      fp.sub(%r{\.[^/]*\Z}, '').tr('/', '.').gsub(/\A\.+|\.+\Z/, '')
    end

    def self.description_for(notification)
      notification.example.full_description
    end

    def self.example_group_file_path_for(notification)
      metadata = notification.example.metadata[:example_group]
      while parent_metadata = metadata[:parent_example_group]
        metadata = parent_metadata
      end
      metadata[:file_path]
    end

    def self.duration_for(notification)
      notification.example.execution_result.run_time
    end
  end
end
# rubocop:enable Lint/AssignmentInCondition
