require 'ostruct'

require 'redis'
require 'httparty'
require 'link_header'
require 'ims'
require 'nokogiri'

require "canvas_oauth/config"
require "canvas_oauth/canvas_application"
require 'canvas_oauth/canvas_api'
require 'canvas_oauth/canvas_api_extensions'
require 'canvas_oauth/canvas_cache'
require 'canvas_oauth/canvas_config'
require 'canvas_oauth/redis_config'

module CanvasOauth
  mattr_accessor :app_root

  def self.setup
    yield self
  end

  def self.config
    yield(CanvasOauth::Config)
  end
end

require "canvas_oauth/engine"

