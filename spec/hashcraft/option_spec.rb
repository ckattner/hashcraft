# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

RSpec.describe Hashcraft::Option do
  let(:name) { 'Example' }

  let(:config) do
    {
      meta: {
        localize: true
      }
    }
  end

  subject { described_class.new(name, config) }

  specify '#meta is top-level type-insensitive' do
    expect(subject.meta(:localize)).to be true
    expect(subject.meta('localize')).to be true
  end
end
