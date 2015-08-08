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

  def request(method_name, params = {})
    url = [Librato::Client::API_VERSION]
    url << @root if @root
    url << @name
    url << @resource_id if @resource_id

    res = @conn.send(method_name) do |req|
      req.url url.join('/')
      req.params = params
    end

    if res.body.kind_of?(Hash) and res.body.has_key?('query')
      pageable_resources = Librato::Client::PageableResources.new(
        self, @name, method_name, params, res.body)

      if @options[:expand_pageable_resources]
        pageable_resources.each_resource.to_a
      else
        pageable_resources
      end
    else
      res.body
    end
  end

  def method_missing(name, *args, &block)
    unless @methods.include?(name)
      raise NoMethodError, "undefined method: #{name} for #{self.inspect}"
    end

    unless (0..1).include?(args.length)
      raise ArgumentError, "wrong number of arguments (#{args.length} for 0..1)"
    end

    if SUB_RESOURCES.has_key?(name)
      root = [@name]
      root << @resource_id if @resource_id

      Librato::Client::Resource.new(
        @conn, root.join('/'), name, args[0], SUB_RESOURCES[name], @options)
    else
      params = args[0]

      if not params.nil? and not params.kind_of?(Hash)
        raise TypeError, "wrong argument: #{params.inspect} (expected Hash)"
      end

      request(name, params || {}, &block)
    end
  end
end
