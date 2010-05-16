module Devise
  module Orm
    module Mongoid
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

        field name, { :type => type }.merge(options)
      end
    end
  end
end

Mongoid::Document::ClassMethods.send(:include, Devise::Models)
