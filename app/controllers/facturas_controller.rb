require_relative "../../app/models/factura"
require_relative "../../app/models/linea_factura"
require_relative "../../app/models/producto"

class FacturasController < ApplicationController
  def nueva
    path = Rails.root.join("app", "data", "productos.json")
    productos = File.exist?(path) ? JSON.parse(File.read(path), symbolize_names: true) : []
    @productos = productos.map { |prod| Producto.new(**prod) }
     productos_path = Rails.root.join("app", "data", "productos.json")
    impuestos_path = Rails.root.join("app", "data", "impuestos.json")

    @productos = File.exist?(productos_path) ? JSON.parse(File.read(productos_path), symbolize_names: true) : []
    @impuestos_config = File.exist?(impuestos_path) ? JSON.parse(File.read(impuestos_path), symbolize_names: true) : []
    impuestos_path = Rails.root.join("app", "data", "impuestos.json")
    @impuestos_config = File.exist?(impuestos_path) ? JSON.parse(File.read(impuestos_path), symbolize_names: true) : []
  end

  def crear
    facturas_path = Rails.root.join("app", "data", "facturas.json")
    historial = File.exist?(facturas_path) ? JSON.parse(File.read(facturas_path), symbolize_names: true) : []

    numero = historial.empty? ? 1 : historial.last[:numero].to_i + 1
    cliente = params[:cliente]

    seleccionados = params[:productos_seleccionados]&.map(&:to_i) || []
    lineas = []

    params[:lineas].each_with_index do |linea, idx|
      next unless seleccionados.include?(idx)
      next if linea[:codigo].blank?

      lineas << LineaFactura.new(
        codigo_producto: linea[:codigo],
        cantidad: linea[:cantidad],
        precio_unitario: linea[:precio]
      )
    end

    impuestos = if params[:impuestos]
      params[:impuestos].map do |imp_string|
        nombre, tasa = imp_string.split(":")
        { nombre: nombre, tasa: tasa.to_f }
      end
    else
      []
    end

    factura = Factura.new(
      numero: numero,
      cliente: cliente,
      lineas: lineas,
      impuestos: impuestos
    )

    historial << factura.to_hash
    File.write(facturas_path, JSON.pretty_generate(historial))

    redirect_to "/facturas/ver?numero=#{numero}", notice: "Factura generada con éxito."
  end

  def ver
    numero = params[:numero].to_i
    path = Rails.root.join("app", "data", "facturas.json")
    @facturas = File.exist?(path) ? JSON.parse(File.read(path), symbolize_names: true) : []
    @factura = @facturas.find { |f| f[:numero] == numero }

    unless @factura
      redirect_to "/facturas/listar", alert: "Factura no encontrada."
    end
  end

  def listar
    path = Rails.root.join("app", "data", "facturas.json")
    @facturas = File.exist?(path) ? JSON.parse(File.read(path), symbolize_names: true) : []
  end

  def pdf
    @factura = cargar_facturas.find { |f| f[:numero] == params[:numero].to_i }
    @cliente = cargar_clientes.find { |c| c[:id] == @factura[:cliente_id] }
    @impuestos = cargar_impuestos

    @items_con_detalles = @factura[:items].map do |item|
      producto = @productos.find { |p| p[:codigo] == item[:producto_codigo] }
      impuesto = @impuestos.find { |i| i[:id] == item[:impuesto_id] }
      {
        producto: producto,
        cantidad: item[:cantidad],
        precio_unitario: item[:precio_unitario],
        impuesto: impuesto,
        subtotal: item[:precio_unitario].to_f * item[:cantidad].to_i
      }
    end

    @subtotal = @items_con_detalles.sum { |i| i[:subtotal] }
    @total_impuestos = @items_con_detalles.sum do |i|
      i[:impuesto] ? (i[:subtotal] * (i[:impuesto][:porcentaje].to_f / 100.0)) : 0
    end
    @total = @subtotal + @total_impuestos

    respond_to do |format|
      format.pdf do
        render pdf: "factura_#{@factura[:numero]}",
              template: "facturacion/pdf",
              layout: "pdf",
              formats: "html",
              encoding: "UTF-8",
              show_as_html: params[:debug].present?
      end
    end
  end
end
