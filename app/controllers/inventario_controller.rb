require_relative "../../app/models/producto"
class InventarioController < ApplicationController
  def index
    path = Rails.root.join("app", "data", "productos.json")

    if File.exist?(path)
      json_data = File.read(path)
      array_de_productos = JSON.parse(json_data, symbolize_names: true)
      @productos = array_de_productos.map { |prod| Producto.new(**prod) }
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
