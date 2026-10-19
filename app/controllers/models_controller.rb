class ModelsController < ApplicationController
  def index
    @models = ModelCatalog.all
  end

  def show
    @model = RubyLLM.models.find(params[:id], provider: params[:provider])
  end

  def refresh
    RubyLLM.models.refresh
    redirect_to models_path, notice: "Models refreshed successfully"
  end
end
