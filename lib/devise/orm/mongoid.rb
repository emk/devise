module Devise
  module Orm
    module Mongoid
      # These are always included in Mongoid::Document.
      module AutomaticClassMethods
        # Similar to attr_accessible, but it must appear _before_ the
        # 'devise' declaration.
        def devise_accessible(*attrs)
          @devise_accessible ||= []
          @devise_accessible.concat(attrs.map {|a| a.to_sym })
        end
      end
      ::Mongoid::Document::ClassMethods.send(:include, AutomaticClassMethods)

      module InstanceMethods
        def update_attribute(name, value)
          update_attributes(name => value)
        end
      end

      def self.included_modules_hook(klass)
        klass.send(:extend, self)
        klass.send(:include, InstanceMethods)
        klass.send(:include, ::Mongoid::Timestamps)

        class << klass
          alias_method(:validates_uniqueness_of_without_scope_fix,
                       :validates_uniqueness_of)
          alias_method(:validates_uniqueness_of,
                       :validates_uniqueness_of_with_scope_fix)
        end

        yield

        klass.devise_modules.each do |mod|
          klass.send(mod) if klass.respond_to?(mod)
        end
      end

      # Mongoid's validates_uniqueness_of doesn't support passing an array
      # for :scope.  We can patch around that to a certain extent here.
      def validates_uniqueness_of_with_scope_fix(field, options)
        if options.has_key?(:scope) && options[:scope].instance_of?(Array)
          options = options.dup
          scope = options.delete(:scope)
          if scope.length == 0
            # Do nothing.
          elsif scope.length == 1
            options[:scope] = scope.first
          else
            raise("Mongoid validates_uniqueness_of can't support :scope of " +
                  "#{scope.inspect} for field #{field.inspect}")
          end
        end
        validates_uniqueness_of_without_scope_fix(field, options)
      end

      include Devise::Schema

      def apply_schema(name, type, options={})
        return unless Devise.apply_schema

        # Convert DateTime fields to Time fields for consitency with
        # MongoMapper, and to make some of the unit tests pass.
        type = Time if type == DateTime

        # Determine whether this attr should be accessible via bulk update.
        accessible = true
        unless @devise_accessible.nil?
          accessible = @devise_accessible.include?(name.to_sym)
        end

        field name, { :type => type, :accessible => accessible }.merge(options)
      end
    end
  end
end

Mongoid::Document::ClassMethods.send(:include, Devise::Models)
