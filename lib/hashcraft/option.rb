# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'mutators'

module Hashcraft
  # Defines a method and corresponding attribute for a craftable class.
  class Option
    attr_reader :craft,
                :default,
                :eager,
                :key,
                :mutator,
                :name

    alias eager? eager

    def initialize(name, opts = {}) # :nodoc:
      raise ArgumentError, 'name is required' if name.to_s.empty?

      @craft         = opts[:craft]
      @default       = opts[:default]
      @eager         = opts[:eager] || false
      @internal_meta = symbolize_keys(opts[:meta] || {})
      @key           = opts[:key].to_s
      @mutator       = opts[:mutator]
      @name          = name.to_s

      freeze
    end

    def value!(data, key, value) # :nodoc:
      Mutators.instance.value!(mutator, data, key, value)
    end

    # Options are sent into transformers as arguments.  Leverage the meta key for an option
    # to store any additional data that you may need in transformers.  This method provides a
    # quick message-based entry point into inspecting the meta key's value.
    def meta(key)
      internal_meta[key.to_s.to_sym]
    end

    def hash_key # :nodoc:
      key.empty? ? name : key
    end

    def craft_value(value, &block) # :nodoc:
      craft ? craft.new(value, &block) : value
    end

    private

    attr_reader :internal_meta

    def symbolize_keys(hash)
      hash.transform_keys(&:to_sym)
    end
  end
end
