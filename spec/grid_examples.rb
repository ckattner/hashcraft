# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

class ExclamationTransformer
  include Singleton

  def transform(value, option)
    option.meta(:exclaim) ? "#{value}!!!" : value
  end
end

class HeaderBase < Hashcraft::Base
  key_transformer :camel_case

  value_transformer ExclamationTransformer.instance
end

class Header < HeaderBase
  option :title, eager: true,
                 default: 'Untitled Grid',
                 meta: { exclaim: true }

  option :message

  option :i_should_be_camel_cased, default: '',
                                   eager: true,
                                   meta: { exclaim: true }
end

class Content < Hashcraft::Base
  option :property
end

class Column < Hashcraft::Base
  option :header, :property

  option :context, mutator: :hash,
                   eager: true,
                   default: {}

  option :content, craft: Content,
                   mutator: :array,
                   key: :contents
end

class Grid < Hashcraft::Base
  option :api_url,
         :name

  option :child, key: :children,
                 mutator: :flat_array

  option :context, mutator: :hash

  option :header, craft: Header

  option :max_width, eager: true,
                     default: '350px'

  option :column, craft: Column,
                  mutator: :array,
                  key: :columns,
                  eager: true,
                  default: []

  option :reorderable, eager: true,
                       default: false,
                       mutator: :always_true

  option :disable,     key: :disabled,
                       mutator: :always_false,
                       default: true
end
