# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashcraft
  # Singleton that knows how to register and retrieve mutator instances.
  # Entries can either be instances that respond to value! or procs that accept three arguments.
  class Mutators < Generic::Registry # :nodoc:
    FUNCTIONS = {
      always_false: ->(data, key, _value) { data[key] = false },
      always_true: ->(data, key, _value) { data[key] = true },
      array: ->(data, key, value)  { (data[key] ||= []) << value },
      flat_array: lambda do |data, key, value|
        data[key] ||= []

        if value.is_a?(::Array)
          data[key] += value
        else
          data[key] << value
        end
      end,
      hash: ->(data, key, value) { (data[key] ||= {}).merge!(value || {}) },
      property: ->(data, key, value) { data[key] = value },
    }.freeze

    private_constant :FUNCTIONS

    def initialize
      # append on the default case
      super(FUNCTIONS.merge('': FUNCTIONS[:property]))
    end

    def value!(name, data, key, value)
      object = resolve(name)
      method = object.is_a?(Proc) ? :call : :value!

      object.send(method, data, key, value)
    end
  end
end
