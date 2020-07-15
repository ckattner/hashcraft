# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashcraft
  module Generic # :nodoc: all
    # A general data structure that can register and resolve objects by name.
    # It also will act as a pass-thru if a non-string or non-symbol is passed through.
    class Registry
      include Singleton

      class << self
        extend Forwardable

        def_delegators :instance,
                       :register,
                       :register_all,
                       :resolve
      end

      def initialize(map = {})
        @map = {}

        register_all(map)

        freeze
      end

      def register_all(map)
        (map || {}).each { |k, v| register(k, v) }

        self
      end

      def register(name, value)
        @map[name.to_s] = value

        self
      end

      def resolve(value)
        return value unless lookup?(value)

        map[value.to_s] || raise(ArgumentError, "registration: #{value} not found")
      end

      private

      attr_reader :map

      def lookup?(value)
        value.is_a?(String) || value.is_a?(Symbol) || value.nil?
      end
    end
  end
end
