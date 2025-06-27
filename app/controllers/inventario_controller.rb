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

  def crear
    path = Rails.root.join("app", "data", "productos.json")

    productos = if File.exist?(path)
                  file = File.read(path)
                  JSON.parse(file)
    else
                  []
    end

    # Se crea la nueva instancia
    nuevo_producto = Producto.new(
      codigo: params[:codigo],
      nombre: params[:nombre],
      precio: params[:precio],
      stock: params[:stock]
    )

    productos << nuevo_producto.to_hash

    File.write(path, JSON.pretty_generate(productos))

    redirect_to "/inventario/index", notice: "Producto agregado correctamente"
  end

  def agregar
  end

  def editar
    codigo = params[:codigo]
  end
end
