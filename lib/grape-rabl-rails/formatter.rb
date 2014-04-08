module Grape
  module Formatter
    class RablRails

      Rabl = ::RablRails
      Rabl.configuration.allow_empty_format_in_template = true

      def initialize(options)
        @view_root    = options.fetch(:views).dup.freeze
        @view_context = Rabl::Renderer::ViewContext.new(nil, view_path: @view_root)
        self.freeze

      rescue KeyError => e
        raise ConfigurationError, e.message
      end

      require 'byebug'
      def call(block_retval, env)
        format, endpoint = env.values_at *%w(api.format api.endpoint)

        if (template = extract_template(endpoint))
          render template, format, endpoint.instance_values.update(result: block_retval)
        else
          fallback = Grape::Formatter.const_get(format.to_s.capitalize)
          fallback.call(block_retval, env)
        end
      end

      private

      def render(template, format, locals)
        t = Rabl::Library.instance.compile_template_from_path(template, @view_context)
        Rabl::Renderers.const_get(format.to_s.upcase).render(t, @view_context, locals)
      rescue => e
        byebug
        1
      end
      require 'byebug'

      def extract_template(endpoint)
        template = extract_from_route_options(endpoint)
        return unless template

        # Concatenate the namespace, unless the template starts with '/'
        #
        if template && template[0] != '/' && (namespace = compute_namespace(endpoint))
          template = File.join(namespace, template)
        end

        return template
      end


      def extract_from_route_options(endpoint)
        options = endpoint.options[:route_options]
        options.fetch(:rabl) if options.key?(:rabl)
      end

      def compute_namespace(endpoint)
        namespace = endpoint.settings.stack.inject([]) do |result, item|
          result.tap do
            if (ns = item[:namespace])
              result << (ns.options[:rabl] ||
                         ns.space.sub(/\/:\w+/, ''))
            end
          end
        end

        namespace.join('/') unless namespace.size.zero?
      end

    end
  end
end
