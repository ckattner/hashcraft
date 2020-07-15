# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'dsl'
require_relative 'transformers'

module Hashcraft
  # Super-class for craftable objects.
  class Base
    extend Dsl
    extend Forwardable

    def_delegators :'self.class',
                   :option_set,
                   :find_option,
                   :key_transformer_to_use,
                   :value_transformer_to_use

    def initialize(opts = {}, &block)
      @data = {}

      load_default_data
      load_opts(opts)

      return unless block_given?

      if block.arity == 1
        yield self
      else
        instance_eval(&block)
      end
    end

    # Main compilation method.  Once an object is hydrated, you can call this method to get the
    # materialized hash.
    def to_h
      data.each_with_object({}) do |(key, value), memo|
        method = value.is_a?(Array) ? :evaluate_values! : :evaluate_value!

        send(method, memo, key, value)
      end
    end

    private

    attr_reader :data

    def load_default_data
      option_set.each { |option| default!(option) }
    end

    def load_opts(opts)
      (opts || {}).each { |k, v| send(k, v) }
    end

    def evaluate_values!(data, key, values)
      data[key] = values.map { |value| value.is_a?(Hashcraft::Base) ? value.to_h : value }

      self
    end

    def evaluate_value!(data, key, value)
      data[key] = (value.is_a?(Hashcraft::Base) ? value.to_h : value)

      self
    end

    def default!(option)
      return self unless option.eager?

      key   = hash_key(option)
      value = Transformers.instance.transform(value_transformer_to_use, option.default.dup, option)

      data[key] = value

      self
    end

    def value!(option, value, &block)
      key   = hash_key(option)
      value = option.craft_value(value, &block)
      value = Transformers.instance.transform(value_transformer_to_use, value, option)

      option.value!(data, key, value)

      self
    end

    def hash_key(option)
      Transformers.instance.transform(key_transformer_to_use, option.hash_key, option)
    end
  end
end
