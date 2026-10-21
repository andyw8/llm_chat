# The chat models RubyLLM knows about, and whether each one's provider has
# the configuration it needs. Availability is a local check of the provider's
# declared credentials/endpoints, not a network call.
class ModelCatalog
  class << self
    def all
      sorted(RubyLLM.models.chat_models.all)
    end

    def available
      all.select { |model| available?(model) }
    end

    def configured?
      available.any?
    end

    def available?(model)
      !!model.provider_class&.configured?(RubyLLM.config)
    end

    def default_model
      RubyLLM.models.find(RubyLLM.config.default_model)
    rescue RubyLLM::ModelNotFoundError
      nil
    end

    def default_model_available?
      !!default_model && available?(default_model)
    end

    def default_model_option
      option_value(default_model) if default_model_available?
    end

    def option_value(model)
      [ model.provider, model.id ].join(":")
    end

    private

    def sorted(models)
      models.sort_by { |model| [ model.provider.to_s, model.name.to_s ] }
    end
  end
end
