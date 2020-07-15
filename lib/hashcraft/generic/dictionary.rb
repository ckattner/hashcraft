# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashcraft
  module Generic # :nodoc: all
    # Dictionary structure defining how we want to organize objects.  Basically a type-insensitive
    # hash where each key is the object's value for the specified key.
    # All keys are #to_s evaluated in order to achieve the type-insensitivity.
    class Dictionary
      extend Forwardable

      attr_reader :key, :map

      def_delegators :map, :values

      def initialize(key: :key)
        raise ArgumentError, 'key is required' if key.to_s.empty?

        @key = key
        @map = {}

        freeze
      end

      def each(&block)
        return enum_for(:each) unless block_given?

        values.each(&block)
      end

      def find(key)
        @map[key.to_s]
      end

      def add(object)
        object_key = object.send(key)

        @map[object_key] = object

        self
      end

      def merge!(other)
        map.merge!(other.map)

        self
      end
    end
  end
end
