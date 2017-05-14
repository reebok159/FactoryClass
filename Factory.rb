class Factory
  class << self
    alias_method :nnew, :new
  end

  def self.new(*args, &block)
    attrs = args.map do |a|
      case a
      when Symbol
    	  a
      when String
    	  a.to_sym
      end
    end

    klass = Class.new self do

    	attr_accessor(*attrs)

      def self.new(*attrs, &block)
       nnew(*attrs, &block)
      end

      const_set :FACTORY_ATTRS, attrs
    end

    klass.module_eval(&block) if block

    klass
  end

  def _attrs
    self.class::FACTORY_ATTRS
  end

  private :_attrs

  def initialize(*args)
    attrs = _attrs
    unless attrs.length <= args.length
      raise ArgumentError
    end
    attrs.each_with_index do |attr, i|
      instance_variable_set(:"@#{attr}", args[i])
    end
  end


  def [](key)
    if key.kind_of?(Integer)
      begin
        key = _attrs[key]
      rescue NameError
     	  puts "Wrong Key"
      end
    else
      raise NameError unless instance_variable_defined?(:"@#{key}")
    end
    instance_variable_get(:"@#{key}")
  end


  def []=(key, value)
    if key.kind_of?(Integer)
      begin
        key = _attrs[key]
      rescue NameError
     	  puts "Wrong Key"
      end
    else
      raise NameError unless instance_variable_defined?(:"@#{key}")
    end
    instance_variable_set(:"@#{key}", value)
  end


  def size
    self._attrs.length
  end


  alias_method :length, :size


  def to_a
    res = _attrs.collect{ |key| instance_variable_get(:"@#{key}") }

    res
  end


  def ==(other)
    return false if self.class != other.class
    other.to_a == self.to_a
  end
end

