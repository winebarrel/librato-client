class Librato::Client
  ENDPOINT = 'https://metrics-api.librato.com'
  API_VERSION = 'v1'
  USER_AGENT = "Ruby Librato Client #{Librato::Client::VERSION}"

  DEFAULT_ADAPTERS = [
    Faraday::Adapter::NetHttp,
    Faraday::Adapter::Test
  ]

  RESOURCES = {
    :metrics      => [:get, :post, :put, :delete],
    :annotations  => [:get, :post, :put, :delete],
    :alerts       => [:get, :post, :put, :delete, :status],
    :api_tokens   => [:get, :post, :put, :delete],
    :charts       => [:get, :post,       :delete],
    :dashboards   => [:get, :post, :put, :delete],
    :instruments  => [:get, :post, :put, :delete],
    :jobs         => [:get                      ],
    :services     => [:get, :post, :put, :delete],
    :sources      => [:get,        :put, :delete],
    :spaces       => [:get, :post, :put, :delete, :charts],
    :users        => [:get, :post, :put, :delete],
  }

  RESOURCE_OPTIONS = {
    :expand_pageable_resources => true,
    :raise_error_if_not_exist  => false,
    :wrap_faraday_client_error => true,
    :default_alerts_version    => 2,
  }

  def initialize(options)
    unless user = options.delete(:user)
      raise ArgumentError, ':user is required'
    end

    unless token = options.delete(:token)
      raise ArgumentError, ':token is required'
    end

    @debug = options.delete(:debug)
    @resource_options = {}

    RESOURCE_OPTIONS.each do |key, default_value|
      if options.has_key?(key)
        @resource_options[key] = options.delete(key)
      else
        @resource_options[key] = default_value
      end
    end

    options[:url] ||= ENDPOINT

    @conn = Faraday.new(options) do |faraday|
      faraday.request  :url_encoded
      faraday.response :json, :content_type => /\bjson\b/
      faraday.response :raise_error
      faraday.response :logger if @debug

      faraday.basic_auth user, token

      yield(faraday) if block_given?

      unless DEFAULT_ADAPTERS.any? {|i| faraday.builder.handlers.include?(i) }
        faraday.adapter Faraday.default_adapter
      end
    end

    @conn.headers[:user_agent] = USER_AGENT
  end

  def method_missing(name, *args)
    unless RESOURCES.has_key?(name)
      raise NoMethodError, "undefined method: #{name} for #{self.inspect}"
    end

    unless (0..1).include?(args.length)
      raise ArgumentError, "wrong number of arguments (#{args.length} for 0..1)"
    end

    Librato::Client::Resource.new(
      @conn, nil, name, args[0], RESOURCES[name], @resource_options)
  end
end
