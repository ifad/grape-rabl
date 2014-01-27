module Grape
  module RablRails
    module Render
      def render(options = {})
        env['api.endpoint'].options[:route_options][:rabl] = options.delete(:rabl)
      end
    end
  end
end

Grape::Endpoint.send(:include, Grape::Render::RablRails)
