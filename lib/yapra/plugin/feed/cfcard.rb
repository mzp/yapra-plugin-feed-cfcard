require 'yapra/plugin/base'

module Yapra::Plugin::Feed
  class Cfcard < Yapra::Plugin::Base
    VERSION = "0.0.1"
    def run(data)
      p config
      []
    end
  end
end
