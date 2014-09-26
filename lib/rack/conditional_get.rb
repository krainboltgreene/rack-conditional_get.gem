module Rack
  # Middleware that enables conditional GET using If-None-Match and
  # If-Modified-Since. The application should set either or both of the
  # Last-Modified or Etag response headers according to RFC 2616. When
  # either of the conditions is met, the response body is set to be zero
  # length and the response status is set to 304 Not Modified.
  #
  # Applications that defer response body generation until the body's each
  # message is received will avoid response body generation completely when
  # a conditional GET matches.
  #
  # Adapted from Michael Klishin's Merb implementation:
  # https://github.com/wycats/merb/blob/master/merb-core/lib/merb-core/rack/middleware/conditional_get.rb
  module ConditionalGet
    require_relative "conditional_get/version"
    VERB_KEY = "REQUEST_METHOD"
    MODIFIED_SINCE_KEY = "HTTP_IF_MODIFIED_SINCE"
    NONE_MATCH_KEY = "HTTP_IF_NONE_MATCH"
    ETAG_KEY = "ETag"
    LAST_MODIFIED_KEY = "Last-Modified"

    def initialize(stack)
      @stack = stack
    end

    def call(env)
      @env = env
      @status, @headers, @body = @app.call(environment)
      if (get? || head?) && (@status == 200 && fresh?)
        @status = 304
        headers.delete("Content-Type")
        headers.delete("Content-Length")
        body = Rack::BodyProxy.new([]) do
          @body.close if @body.respond_to?(:close)
        end
        [@status, @headers, body]
      else
        @app.call(env)
      end
    end

    private def fresh?
      modified_since || etag_matches?
    end

    private def env
      @env
    end

    private def headers
      @headers
    end

    private def none_match
      @env[NONE_MATCH_KEY]
    end

    private def etag
      headers[ETAG_KEY]
    end

    private def etag_matches?
      etag && none_match && etag == none_match
    end

    private def modified_since
      @env[MODIFIED_SINCE_KEY]
    end

    private def last_modified
      headers[LAST_MODIFIED_KEY]
    end

    private def modified_since?
      last_modified && modified_since && modified_since >= last_modified
    end

    private def get?
      verb == "GET"
    end

    private def get?
      verb == "HEAD"
    end

    private def verb
      env[VERB_KEY]
    end
  end
end
