class Librato::Client::Resource
  def initialize(name, resource_id, methods, conn)
    @name = name
    @resource_id = resource_id
    @methods = methods
    @conn = conn
  end

  def request(method_name, params = {})
    url = "/#{Librato::Client::API_VERSION}/#{@name}"
    url << "/#{@resource_id}" if @resource_id

    res = @conn.send(method_name) do |req|
      req.url url
      req.params = params
    end

    if res.body.kind_of?(Hash) and res.body.has_key?('query')
      Librato::Client::PageableResources.new(
        self, @name, method_name, params, res.body)
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

    params = args[0]

    if not params.nil? and not params.kind_of?(Hash)
      raise TypeError, "wrong argument: #{params.inspect} (expected Hash)"
    end

    request(name, params || {}, &block)
  end
end
