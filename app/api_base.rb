class ApiBase < Grape::API
  default_format :hal
  parser :hal, Grape::Parser::Json
  error_formatter :hal, Grape::ErrorFormatter::Json

  rescue_from :all

  class Formatter
    def call(object, env)
      if object == :top_level
        YaksCfg.yaks.serialize(object, env: env, mapper: RootMapper)
      elsif object.class == String
        { message: object }.to_json
      else
        YaksCfg.yaks.serialize(object, env: env)
      end
    end
  end

  Yaks::Format.mime_types.each do |name, mime_type|
    content_type name, mime_type
    formatter name, Formatter.new
  end

  get do
    :top_level
  end

  helpers do
    def declared_params
      declared(params, include_missing: false)
    end
  end
  mount ApiUsers
end
