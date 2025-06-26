class InventarioController < ApplicationController
  def index
    path = Rails.root.join("app", "data", "productos.json")

    if File.exist?(path)
      file = File.read(path)
      @productos = JSON.parse(file, symbolize_names: true)
    else
      @productos = []
    end
  end

  def agregar
  end

  def editar
    codigo = params[:codigo]
  end
end
