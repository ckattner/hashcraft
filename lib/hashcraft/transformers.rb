# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashcraft
  # Singleton that knows how to register and retrieve transformer instances.
  # Entries can either be instances that respond to transform or procs that accept two arguments.
  class Transformers < Generic::Registry # :nodoc:
    FUNCTIONS = {
      camel_case: lambda do |value, _option|
        return value.to_s if value.to_s.empty?

        name = value.to_s.split('_').collect(&:capitalize).join

        name[0, 1].downcase + name[1..-1]
      end,
      pascal_case: ->(value, _option) { value.to_s.split('_').collect(&:capitalize).join },
      pass_thru: ->(value, _option) { value }
    }.freeze

    private_constant :FUNCTIONS

    def initialize
      # append on the default case
      super(FUNCTIONS.merge('': FUNCTIONS[:pass_thru]))
    end

    def transform(name, value, option)
      object = resolve(name)
      method = object.is_a?(Proc) ? :call : :transform

      object.send(method, value, option)
    end
  end
end
