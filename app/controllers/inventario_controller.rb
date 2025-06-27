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
                  JSON.parse(file, symbolize_names: true)
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

    # Validar que el código sea único
    # En la validacón se pasa a minuscula para evitar repetir letras con la mimsa combinacion de numeros
    if productos.any? { |p| p[:codigo].to_s.downcase == nuevo_producto.codigo.to_s.downcase }
      flash[:alert] = "El código '#{nuevo_producto.codigo}' no esta disponible."
      redirect_to "/inventario/agregar"
      return
    end

    unless nuevo_producto.valido?
      flash[:alert] = "Por favor, complete todos los campos con valores válidos."
      redirect_to "/inventario/agregar"
      return
    end

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
