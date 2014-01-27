module Grape
  module Formatter
    module RablRails
      class << self

        attr_reader :env
        attr_reader :endpoint

        def call(body, env)

          @env = env
          @endpoint = env['api.endpoint']

          if (template = rabl_template)
            ::RablRails.render nil, template,
              view_path: view_root, format: view_format,
              locals: endpoint.instance_variables.inject({}) {|h,v|
                h.update(v.to_s.sub('@', '') => endpoint.instance_variable_get(v))
              }
          else
            Grape::Formatter::Json.call body, env
          end
        end

        private

          def rabl_template
            template = endpoint.options[:route_options][:rabl]
            return template if template
          end

          def view_root
            env['api.rabl.root'] or
              raise "Use Rack::Config to set 'api.rabl.root' in config.ru"
          end

          def view_format
            env['api.format']
          end

      end
    end
  end
end
