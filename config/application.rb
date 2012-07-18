# MARSHA MARSHA MARSHA !!!!!!

require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'mime/types'
require 'echonest'
require 'mp3info'
require 'digest/md5'
require 'base64'
require 'uri'
require 'youtube_it'
require 'pathname'
require 'soundcloud'
require 'rack/utils'
require 'juggernaut'

require 'openssl'
require 'open-uri'

#if Rails.env == "development"
#  silence_warnings do
#    require 'pry'
#    IRB = Pry
#  end
#end
# This class provides a Paperclip plugin compliant interface for an "upload" file
# where that uploaded file is actually coming from a URL.  This class will download
# the file from the URL and then respond to the necessary methods for the interface,
# as required by Paperclip so that the file can be processed and managed by
# Paperclip just as a regular uploaded file would.
#
class UrlTempfile < Tempfile
  attr :content_type

  def initialize(url)
    @url = URI.parse(url)

    # see if we can get a filename
    raise "Unable to determine filename for URL uploaded file." unless original_filename

    begin
      # HACK to get around inability to set VERIFY_NONE with open-uri
      old_verify_peer_value = OpenSSL::SSL::VERIFY_PEER
      openssl_verify_peer = OpenSSL::SSL::VERIFY_NONE

      super('urlupload')
      Kernel.open(url) do |file|
        @content_type = file.content_type
        raise "Unable to determine MIME type for URL uploaded file." unless content_type

        self.write file.read.force_encoding("UTF-8")
        self.flush
      end
    ensure
      openssl_verify_peer = old_verify_peer_value
    end
  end

  def original_filename
    # Take the URI path and strip off everything after last slash, assume this
    # to be filename (URI path already removes any query string)
    match = @url.path.match(/^.*\/(.+)$/)
    return (match ? match[1] : nil)
  end

  protected

  def openssl_verify_peer=(value)
    silence_warnings do
      OpenSSL::SSL.const_set("VERIFY_PEER", value)
    end
  end
end


# END HACK

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  #Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  Bundler.require(:default, :assets, Rails.env)
end

module Ish
  class Application < Rails::Application

    config.autoload_paths += Dir["#{config.root}/lib/**/"]


    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true
  end
end

#nihilistic existensialism rules

Thread.new do
  Juggernaut.subscribe do |event, data|
    puts "event: #{event} data: #{data}"
    if event == :subscribe
      # set on load through cookie not subscribe.
      # current_user isnt right here
    elsif event == :unsubscribe
      user = User.find_by_chat_token(data["channel"])
      user.update_attribute("chat_token", nil)
    end
  end
end
