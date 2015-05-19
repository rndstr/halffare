module Halffare
  VERSION = '0.1.1'
  @@debug = false

  def self.debug=(d)
    @@debug = d
  end
  def self.debug
    @@debug
  end
end
