module Stubhub
  class Document < OpenStruct

    def fields
      @table.keys.map{|k| k.to_s}
    end

    def initialize(data = {})
      raise ArgumentError, "Invalid data passed to Document.new: #{data.inspect}" unless data.is_a?(Hash)
      super(data)
    end

  private
 end
  
  # Based on ideas from MongoMapper
  module APIMapper

    # Assumes data is a hash, underscores camelcase keys
    def initialize(data)
      data.each do |key, value|
        self.send("#{underscore(key)}=", value)
      end
    end

    def self.included(klass)
      klass.send(:include, Stubhub::APIMapper::Keys)
      klass.extend Stubhub::APIMapper::Keys::ClassMethods
      klass.extend Stubhub::APIMapper::Inflectors
    end

    # Pulled out of ActiveSupport::Inflector
    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    module Inflectors
      def demodulize
        self.name.to_s.gsub(/^.*::/, '')
      end 
    end

    module Keys
      module ClassMethods
        def keys
          @keys ||= {}
        end

        def key(*args)
          Key.new(*args).tap do |key|
            keys[key.name.to_sym] = key
            create_accessors_for(key)
            create_predicate_method_for(key) if key.predicate?
          end
        end

        def create_accessors_for(key)
          self.class_eval <<-end_eval
            attr_reader :#{key.name}_before_type_cast

            def #{key.name}
              read_key(:#{key.name})
            end

            def #{key.name}=(value)
              write_key(:#{key.name}, value)
            end
          end_eval
        end

        def create_predicate_method_for(key)
          self.class_eval <<-end_eval
            def #{key.name}?
              predicate_key(:#{key.name})
            end
          end_eval
        end
      end

      def read_key(key_name)
        instance_key = :"@#{key_name}"
        instance_variable_get instance_key
      end

      def write_key(key_name, value)
        instance_variable_set :"@#{key_name}_before_type_cast", value
        key = self.class.keys[key_name]
        casted_value = key.cast(value)
        instance_variable_set :"@#{key_name}", casted_value
      end

      def predicate_key(key_name)
        instance_key = :"@#{key_name}_predicate"
        return instance_variable_get(instance_key) if instance_variable_defined?(instance_key)
        
        value = read_key(key_name)
        key = self.class.keys[key_name]
        predicate_value = key.options[:predicate].call(value)
        instance_variable_set instance_key, predicate_value
      end

    end

    class Key
      attr_accessor :name, :type, :options, :default

      def initialize(*args)
        options_from_args = args.extract_options!
        @name, @type = args.shift.to_s, args.shift
        self.options = (options_from_args || {}).symbolize_keys

        if options.key?(:default)
          self.default = self.options[:default]
        end
      end

      # TODO DUCK TYPE
      def cast(value)
        begin
          case type.to_s
          when "String"
            value.to_s
          when "Integer"
            Integer(value)
          when "Array"
            array = if options[:split_on]
              Array(value.split(options[:split_on]))
            end
            array = array.map{|item| options[:map].call(item)} if options[:map]
            array
          else 
            value
          end
        rescue => e
          puts e.inspect
          puts self.inspect
          puts value.inspect
          raise e
        end
      end

      def predicate?
        options[:predicate]
      end
    end
  end
end
