# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

RSpec.describe Hashcraft::Transformers do
  subject { described_class.instance }

  {
    camel_case: {
      '' => '',
      'frank_rizzo' => 'frankRizzo',
      'frank rizzo' => 'frank rizzo',
      'FRANK_RIZZO' => 'frankRizzo'
    },
    pascal_case: {
      '' => '',
      'frank_rizzo' => 'FrankRizzo',
      'frank rizzo' => 'Frank rizzo',
      'FRANK_RIZZO' => 'FrankRizzo'
    },
    pass_thru: {
      '' => '',
      nil => nil,
      123 => 123
    }
  }.each do |transformer_name, test_cases|
    context transformer_name.to_s do
      test_cases.each do |input, output|
        specify "#{input} => #{output}" do
          expect(subject.transform(transformer_name, input, nil)).to eq(output)
        end
      end
    end
  end
end
