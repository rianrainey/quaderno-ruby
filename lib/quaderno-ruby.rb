require 'ostruct'

require 'quaderno-ruby/exceptions/exceptions'
%w(crud deliver payment).each { |filename| require "quaderno-ruby/behavior/#{ filename }" }
%w(base contact item invoice credit estimate expense recurring document_item payment webhook tax).each { |filename| require "quaderno-ruby/#{ filename }" }

module Quaderno

end