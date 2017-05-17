class Factory
  def self.new(*args, &block)
    raise NameError if args.length == 1 && !args[0].is_a?(Symbol)
    raise ArgumentError if args.length == 0

    attrs = args.map do |value|
      case value
        when Symbol
          value
        when String
          value.to_sym
      end
    end

    Class.new do
      attr_accessor *attrs
      define_method :initialize do |*params|
        if params.length > attrs.length
          raise ArgumentError
        end

        attrs.each_with_index do |attr, i|
          instance_variable_set(:"@#{attr}", params[i])
        end
      end

      define_method :[] do |key|
        if key.is_a?(Integer)
          key = instance_variables[key]
        else
          key = "@#{key}".to_sym
        end
        raise NameError unless key
        raise NameError unless instance_variable_defined?(key)

        instance_variable_get(key)
      end

      define_method :[]= do |key, value|
        if key.is_a?(Integer)
          key = instance_variables[key]
        else
          key = "@#{key}".to_sym
        end

        raise NameError unless key
        raise NameError unless instance_variable_defined?(key)

        instance_variable_set(key, value)
      end

      class_eval &block if block_given?
    end
  end
end
