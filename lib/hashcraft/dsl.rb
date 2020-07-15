# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'option'

module Hashcraft
  # The class API used to define options for a craftable class.  Each class stores its own
  # OptionSet instance along with materializing one for its
  # inheritance chain (child has precedence.)
  module Dsl
    attr_reader :local_key_transformer,
                :local_value_transformer

    # DSL Method used to declare what the sub-class should use as a transformer for all keys.
    # It will follow the typical inheritance chain and find the closest
    # transformer to use (child-first).
    def key_transformer(name)
      tap { @local_key_transformer = name }
    end

    # DSL Method used to declare what the sub-class should use as a transformer for all values.
    # It will follow the typical inheritance chain and find the closest
    # transformer to use (child-first).
    def value_transformer(name)
      tap { @local_value_transformer = name }
    end

    def key_transformer_to_use # :nodoc:
      return @key_transformer_to_use if @key_transformer_to_use

      @key_transformer_to_use =
        ancestors.select { |a| a < Base }
                 .find(&:local_key_transformer)
                 &.local_key_transformer
    end

    def value_transformer_to_use # :nodoc:
      return @value_transformer_to_use if @value_transformer_to_use

      @value_transformer_to_use =
        ancestors.select { |a| a < Base }
                 .find(&:local_value_transformer)
                 &.local_value_transformer
    end

    def find_option(name) # :nodoc:
      option_set.find(name)
    end

    # The main class-level DSL method consumed by sub-classes.  This is the entry-point for the
    # declaration of available options.
    def option(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}

      args.each do |key|
        option = Option.new(key, opts)

        local_option_set.add(option)

        method_name = option.name

        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{method_name}(opts = {}, &block)
            option = find_option('#{method_name}')

            value!(option, opts, &block)
          end
        RUBY
      end

      self
    end

    def option_set # :nodoc:
      @option_set ||=
        ancestors
        .reverse
        .select { |a| a < Base }
        .each_with_object(Generic::Dictionary.new) { |a, memo| memo.merge!(a.local_option_set) }
    end

    def local_option_set # :nodoc:
      @local_option_set ||= Generic::Dictionary.new(key: :name)
    end
  end
end
