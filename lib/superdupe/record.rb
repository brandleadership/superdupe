class Dupe
  class Database #:nodoc:
    class Record < Hash #:nodoc:
      attr_accessor :__model__
      
      def id
        self[:id]
      end
      
      def id=(value)
        self[:id] = value
      end
      
      def method_missing(method_name, *args, &block)
        if attempting_to_assign(method_name)
          method_name = method_name.to_s[0..-2].to_sym
          self[method_name] = args.first
        else
          self[method_name.to_sym]
        end
      end

      def record_inspect
        # if a namespace is available, the titleize method destroy the scope operator
        if class_name = __model__ 
          __model__name.to_s.include?('::') ? "Duped::#{__model__.name.to_s}" : "Duped::#{__model__.name.to_s.titleize}"
        else
          self.class.to_s
        end
        
        "<##{class_name}".tap do |inspection|
          keys.each do |key|
            inspection << " #{key}=#{self[key].inspect}"
          end
          inspection << ">"
        end
      end

      alias_method :hash_inspect, :inspect
      alias_method :inspect, :record_inspect

      def demodulize
        if self.__model__.name.to_s.include?('::')
          self.__model__.name.to_s.demodulize
        else
          self.__model__.name.to_s
        end
      end
      
      private
      def attempting_to_assign(method_name)
        method_name.to_s[-1..-1] == '=' 
      end
    end
  end
end
