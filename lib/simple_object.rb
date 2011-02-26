
# Little patch for Ruby 1.8 to give it BasicObject support
unless defined?(BasicObject)
 class BasicObject
    KEEP_METHODS = %w"__id__ __send__ instance_eval == equal? initialize"

    def self.remove_methods!
      m = (private_instance_methods + instance_methods) - KEEP_METHODS
      m.each{|m| undef_method(m)}
    end
    remove_methods!
  end
end
