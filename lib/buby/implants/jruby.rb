class Buby
  module Implants
    module Object
      def java_proxy?
        false
      end

      def implanted?
        false
      end
    end

    module Enumerable
      # XXX backport for 1.8.7
      def each_with_object(memo)
        inject(memo) do |memo, obj|
          yield obj, memo
        end
      end
    end

    module JavaClass
      def ruby_names_for_java_method meth
        self_java_ref = JRuby.reference(self).javaClass
        target_methods = self_java_ref.getMethods.group_by{|jmeth| jmeth.name}[meth.to_s]
        org.jruby.javasupport.JavaUtil.getRubyNamesForJavaName(target_methods.first.name, target_methods)
      end

      # copies wrapper_id method to java_id and all ruby-like aliases
      # used to re-attach java method proxies to new call wrapper
      #
      # @param java_id target java method (the original java method name)
      def rewrap_java_method java_id
        ruby_names_for_java_method(java_id).each do |ruby_name|
          alias_method(ruby_name, java_id) unless wrapper_id == ruby_name
        end
      end
    end
  end
end

class Object
  include Buby::Implants::Object
end

module Enumerable
  include Buby::Implants::Enumerable unless [].respond_to?(:each_with_object)
end

module Java
  class JavaClass
    include Buby::Implants::JavaClass
  end
end
