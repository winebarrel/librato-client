class Librato::Client::PageableResources
  include Enumerable

  def initialize(resource, name, method_name, params, body)
    @resource = resource
    @name = name
    @method_name = method_name
    @params = params
    @body = body
  end

  def resources
    @body[@name.to_s]
  end

  def length
    @body['query']['length'] || 0
  end

  def offset
    @body['query']['offset'] || 0
  end

  def total
    @body['query']['total'] || 0
  end

  def found
    @body['query']['found'] || 0
  end

  def has_next?
    offset + length < found
  end

  def next_page
    params = @params.merge(:offset => offset + length)
    @resource.request(@method_name, params)
  end

  def each
    page = self

    loop do
      yield(page)
      break unless page.has_next?
      page = page.next_page
    end
  end

  def each_resource(&block)
    if block
      self.each do |page|
        page.resources.each(&block)
      end
    else
      self.enum_for(:each_resource)
    end
  end
end
