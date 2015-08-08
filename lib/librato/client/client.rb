class Librato::Client
  ENDPOINT = 'https://metrics-api.librato.com'
  API_VERSION = 'v1'

  DEFAULT_ADAPTERS = [
    Faraday::Adapter::NetHttp,
    Faraday::Adapter::Test
  ]

  RESOURCES = {
    :metrics      => [:get, :post, :put, :delete],
    :annotations  => [:get, :post, :put, :delete],
    :alerts       => [:get, :post, :put, :delete],
    :api_tokens   => [:get, :post, :put, :delete],
    :chart_tokens => [:get, :post, :put, :delete],
    :dashboards   => [:get, :post, :put, :delete],
    :instruments  => [:get, :post, :put, :delete],
    :jobs         => [:get, :post, :put, :delete],
    :services     => [:get, :post, :put, :delete],
    :sources      => [:get, :post, :put, :delete],
    :spaces       => [:get, :post, :put, :delete],
    :users        => [:get, :post, :put, :delete],
  }

  def initialize(options)
    unless user = options.delete(:user)
      raise ArgumentError, ':user is required'
    end

    unless token = options.delete(:token)
      raise ArgumentError, ':token is required'
    end

    options[:url] ||= ENDPOINT

    @conn = Faraday.new(options) do |faraday|
      faraday.request  :url_encoded
      faraday.response :json, :content_type => /\bjson\b/
      faraday.response :raise_error

      faraday.basic_auth user, token

      yield(faraday) if block_given?

      unless DEFAULT_ADAPTERS.any? {|i| faraday.builder.handlers.include?(i) }
        faraday.adapter Faraday.default_adapter
      end
    end
  end

  def method_missing(name, *args)
    unless RESOURCES.has_key?(name)
      raise NoMethodError, "undefined method: #{name} for #{self.inspect}"
    end

    unless (0..1).include?(args.length)
      raise ArgumentError, "wrong number of arguments (#{args.length} for 0..1)"
    end

    Librato::Client::Resource.new(name, args[0], RESOURCES[name], @conn)
  end
end
