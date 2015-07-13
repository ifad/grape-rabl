module Grape
  module Formatter
    class RablRails

      def initialize(options)
        @view_root = options.fetch(:views).dup.freeze
        self.freeze

      rescue KeyError => e
        raise ConfigurationError, e.message
      end

      def call(block_retval, env)
        format, endpoint = env.values_at *%w(api.format api.endpoint)

        endpoint.instance_variable_set(:@result, block_retval)

        if (template = extract_template(endpoint, env)) && should_rabl(endpoint, block_retval)
          render template, format, endpoint

        else
          fallback = Grape::Formatter.const_get(format.to_s.capitalize)
          fallback.call(block_retval, env)
        end
      end

      private

      def extract_template(endpoint, env)
        template = extract_from_env(env) ||
          extract_from_route_options(endpoint)

        return unless template

        # Concatenate the namespace, unless the template starts with '/'
        #
        namespace = compute_namespace(endpoint)
        if namespace && template && template[0] != '/'
          template = File.join(namespace, template)
        end

        return template
      end

      def extract_from_env(env)
        env['api.rabl']
      end

      def extract_from_route_options(endpoint)
        options = endpoint.options[:route_options]
        options.fetch(:rabl) if options.key?(:rabl)
      end

      def compute_namespace(endpoint)
        namespace = endpoint.namespace_stackable(:namespace).inject([]) do |result, ns|
          result.tap do
            result << (ns.options[:rabl] || ns.space.sub(/\/:\w+/, ''))
          end
        end

        namespace.join('/') unless namespace.size.zero?
      end

      def should_rabl(endpoint, block_retval)
        checker = endpoint.options[:route_options].fetch(:rabl_if, nil)
        checker ? checker.call(block_retval) : true
      end

      def render(template, format, endpoint)
        context  = Context.new(@view_root, template, format, endpoint)
        compiled = context.find_template(template)

        ::RablRails::Library.instance.get_rendered_template(compiled, context)
      end

      class Context
        def initialize(view_root, template, format, endpoint)
          @view_root    = view_root
          @virtual_path = template
          @format       = format
          @endpoint     = endpoint

          @_assigns     = endpoint_instance_variables
        end

        def find_template(template)
          template = lookup_context.find_template(template, [], false)
          return template.source if template
        end

        def lookup_context
          @_lookup_context ||= ::RablRails::Renderer::LookupContext.new(@view_root, @format)
        end

        def respond_to?(meth)
          @endpoint.respond_to?(meth)
        end

        private
          def endpoint_instance_variables
            @endpoint.instance_variables.inject({}) do |h, name|
              h.update(name.to_s.sub('@', '') => @endpoint.instance_variable_get(name))
            end
          end

          def method_missing(meth, *args, &block)
            @endpoint.public_send(meth, *args, &block)
          end
      end

    end
  end
end
