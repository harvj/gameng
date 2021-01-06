module Representers
  class Base
    include Rails.application.routes.url_helpers

    def self.call(record, options={})
      new(record, options).()
    end

    def initialize(record, options)
      @record = record
      @format = options[:format] || nil
      @user = options[:user] || nil
      @options = options
    end

    def call
      record.respond_to?(:length) ? process_records : process_record
    end

    private

    attr_reader :record, :format, :options, :user

    def process_record
      return 'null' unless record.present?
      result = build_object(record)
      format == :json ? result.to_json : result
    end

    def process_records
      result = record.map { |r| build_object(r) }
      format == :json ? result.to_json : result
    end

    def build_object
      raise NotImplementedError.new, 'Subclass responsibility'
    end

    def enum_options(record, field)
      record.class.send(field).keys.map do |option|
        { label: option.humanize.capitalize, value: option }
      end
    end

    def scalar_only?
      options[:scalar] == true
    end
  end
end
