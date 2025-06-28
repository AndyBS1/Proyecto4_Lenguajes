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

  def actualizar
    codigo = params[:codigo]
    campo = params[:campo]
    valor = params[:valor]

    historial_path = Rails.root.join("app", "data", "historial_stock.json")
    path = Rails.root.join("app", "data", "productos.json")
    productos = File.exist?(path) ? JSON.parse(File.read(path), symbolize_names: true) : []

    producto = productos.find { |p| p[:codigo] == codigo }

    unless producto
      flash[:alert] = "Producto no encontrado."
      redirect_to "/inventario/index" and return
    end

    case campo
    when "precio"
      if valor.to_f.to_s == valor || valor.to_i.to_s == valor
        producto[:precio] = valor.to_f
      else
        flash[:alert] = "El precio debe ser un número válido."
        redirect_to "/inventario/editar?codigo=#{codigo}" and return
      end
    when "stock"
      if valor.to_i.to_s == valor
        valor_anterior = producto[:stock].to_i
        nuevo_stock = valor.to_i
        diferencia = nuevo_stock - valor_anterior

        if diferencia != 0
          historial = File.exist?(historial_path) ? JSON.parse(File.read(historial_path)) : []
          registro = HistorialStock.new(codigo_producto: codigo, cambio: diferencia).to_hash
          historial << registro
          File.write(historial_path, JSON.pretty_generate(historial))
        end

        producto[:stock] = valor.to_i
      else
        flash[:alert] = "El stock debe ser un número entero válido."
        redirect_to "/inventario/editar?codigo=#{codigo}" and return
      end
    else
      flash[:alert] = "Campo inválido."
      redirect_to "/inventario/editar?codigo=#{codigo}" and return
    end

    File.write(path, JSON.pretty_generate(productos))
    flash[:notice] = "Producto actualizado exitosamente."
    redirect_to "/inventario/index"
  end

  def historial
    path = Rails.root.join("app", "data", "historial_stock.json")

    if File.exist?(path)
      file = File.read(path)
      @historial = JSON.parse(file, symbolize_names: true)
    else
      @historial = []
    end
  end

  def actualizar_motivo
    index = params[:index].to_i
    nuevo_motivo = params[:motivo]

    historial_path = Rails.root.join("app", "data", "historial_stock.json")
    historial = File.exist?(historial_path) ? JSON.parse(File.read(historial_path), symbolize_names: true) : []

    if historial[index]
      historial[index][:motivo] = nuevo_motivo
      File.write(historial_path, JSON.pretty_generate(historial))
      flash[:notice] = "Motivo actualizado correctamente."
    else
      flash[:alert] = "Registro no encontrado."
    end

    redirect_to "/inventario/historial"
  end

  def eliminar
    codigo = params[:codigo]
    path = Rails.root.join("app", "data", "productos.json")

    productos = File.exist?(path) ? JSON.parse(File.read(path), symbolize_names: true) : []
    # se elimina el producto
    productos.reject! { |p| p[:codigo] == codigo }

    File.write(path, JSON.pretty_generate(productos))
    redirect_to "/inventario/index", notice: "Producto eliminado correctamente."
  end

  def agregar
  end

  def editar
    codigo = params[:codigo]
    path = Rails.root.join("app", "data", "productos.json")

    productos = File.exist?(path) ? JSON.parse(File.read(path), symbolize_names: true) : []
    producto_hash = productos.find { |p| p[:codigo] == codigo }

    if producto_hash.nil?
      flash[:alert] = "Producto no encontrado."
      redirect_to "/inventario/index"
      return
    end

    @producto = Producto.new(**producto_hash)
  end
end
