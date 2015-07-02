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
          Library.on_view_root(@view_root) do
            Library.instance.render template, context: endpoint, format: format
          end
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

      # Re-implement RablRails Library for now - better solutions have to be
      # envisioned by refactoring RablRails' Library itself and decoupling it
      # from Rails' internals.
      #
      class Library
        # HACK override RablRails' Library for now
        silence_warnings { ::RablRails::Library = self } # FIXME FIXME FIXME

        include Singleton

        def initialize
          @cache = {}
        end

        def render(template, options)
          template = compile(template)
          format   = options.fetch(:format, 'JSON').to_s.upcase
          context  = options.fetch(:context)

          ::RablRails::Renderers.const_get(format).new(context).render(template)
        end

        def compile(template)
          path = _lookup(template.to_s)

          if ::RablRails.cache_templates?
            (@cache[path] ||= _compile(path)).dup
          else
            _compile(path)
          end
        end

        # Compatibility for Partial rendering
        alias :compile_template_from_path :compile

        private
        def _compile(path)
          ::RablRails::Compiler.new.compile_source(File.read(path))

        rescue Errno::ENOENT
          raise TemplateNotFound.new(path)
        end

        def _lookup(template)
          template += '.rabl' unless template =~ /\.rabl\Z/
          File.join(Thread.current['grape.rabl.root'], template)
        end

        def self.on_view_root(root)
          # Better this than having race conditions due
          # to instance variables in the Singleton
          Thread.current['grape.rabl.root'] = root
          yield
        ensure
          Thread.current['grape.rabl.root'] = nil
        end
      end

      class ConfigurationError < StandardError
      end

      class TemplateNotFound < StandardError
        def initialize(path)
          @path = path
        end

        def message
          "Template not found: #@path"
        end
      end

    end
  end
end
