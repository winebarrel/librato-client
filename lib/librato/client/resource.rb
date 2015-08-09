class Librato::Client::Resource
  SUB_RESOURCES = {
    :charts => [:get, :post, :put, :delete],
  }

  def initialize(conn, root, name, resource_id, methods, options = {})
    @conn = conn
    @root = root
    @name = name
    @resource_id = resource_id
    @methods = methods
    @options = options
  end

  def request(method_name, params = {}, options = {})
    options = @options.merge(options)

    begin
      url = [Librato::Client::API_VERSION]
      url << @root if @root
      url << @name
      url << @resource_id if @resource_id

      if @name == :alerts and options[:default_alerts_version]
        params[:version] = options[:default_alerts_version]
      end

      res = @conn.send(method_name) do |req|
        req.url url.join('/')

        if [:post, :put].include?(method_name)
          req.headers['Content-Type'] = 'application/json'
          req.body = JSON.dump(params)
        else
          req.params = params
        end
      end

      if res.body.kind_of?(Hash) and res.body.has_key?('query')
        pageable_resources = Librato::Client::PageableResources.new(
          self, @name, method_name, params, res.body)

        if options[:expand_pageable_resources]
          pageable_resources.each_resource.to_a
        else
          pageable_resources
        end
      else
        res.body
      end
    rescue Faraday::ClientError => e
      if not options[:raise_error_if_not_exist] and e.kind_of?(Faraday::ResourceNotFound)
        nil
      else
        if options[:wrap_faraday_client_error]
          e = Librato::Client::Error.new(e)
        end

        raise e
      end
    end
  end

  def method_missing(name, *args, &block)
    unless @methods.include?(name)
      raise NoMethodError, "undefined method: #{name} for #{self.inspect}"
    end

    if SUB_RESOURCES.has_key?(name)
      unless (0..1).include?(args.length)
        raise ArgumentError, "wrong number of arguments (#{args.length} for 0..1)"
      end

      root = [@name]
      root << @resource_id if @resource_id

      Librato::Client::Resource.new(
        @conn, root.join('/'), name, args[0], SUB_RESOURCES[name], @options)
    else
      unless (0..2).include?(args.length)
        raise ArgumentError, "wrong number of arguments (#{args.length} for 0..2)"
      end

      params  = args[0]
      options = args[1]

      [params, options].each do |arg|
        if not arg.nil? and not arg.kind_of?(Hash)
          raise TypeError, "wrong argument: #{arg.inspect} (expected Hash)"
        end
      end

      request(name, params || {}, options || {}, &block)
    end
  end
end
