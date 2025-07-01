class FacturacionController < ApplicationController
  before_action :cargar_datos

  def index
    @facturas = cargar_facturas
  end

  def nueva
    @factura = Factura.new(
      numero: siguiente_numero_factura,
      cliente_id: nil,
      items: []
    )
    @clientes = cargar_clientes
    @impuestos = cargar_impuestos
  end

  def crear
    cliente_id = params[:cliente_id]
    items_data = params[:items] || []

    errores_stock = []

    items = items_data.map do |item_data|
      producto = @productos.find { |p| p[:codigo] == item_data[:producto_codigo] }
      cantidad = item_data[:cantidad].to_i

      if producto.nil?
        errores_stock << "Producto con código #{item_data[:producto_codigo]} no encontrado."
        next
      end

      if cantidad > producto[:stock].to_i
        errores_stock << "El producto '#{producto[:nombre]}' solo tiene #{producto[:stock]} unidades disponibles."
      end

      FacturaItem.new(
        producto_codigo: item_data[:producto_codigo],
        cantidad: cantidad,
        precio_unitario: producto[:precio],
        impuesto_id: item_data[:impuesto_id]
      )
    end.compact

    if errores_stock.any?
      flash[:alert] = errores_stock.join("<br>").html_safe
      redirect_to facturacion_nueva_path and return
    end

    factura = Factura.new(
      numero: siguiente_numero_factura,
      cliente_id: cliente_id,
      items: items
    )

    facturas = cargar_facturas
    factura_hash = factura.to_hash
    factura_hash[:items] ||= []
    facturas << factura_hash

    guardar_facturas(facturas)
    actualizar_stock_factura(factura)

    redirect_to facturacion_index_path, notice: "Factura creada correctamente"
  end


  def mostrar
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
    # Calculamos los totales
    @subtotal = @items_con_detalles.sum { |i| i[:subtotal] }
    @total_impuestos = @items_con_detalles.sum do |i|
      i[:impuesto] ? (i[:subtotal] * (i[:impuesto][:porcentaje].to_f / 100.0)) : 0
    end
    @total = @subtotal + @total_impuestos
  end

  def eliminar
    numero = params[:numero].to_i
    facturas = cargar_facturas
    facturas.reject! { |factura| factura[:numero] == numero }
    guardar_facturas(facturas)

    redirect_to facturacion_index_path, notice: "Factura eliminada exitosamente."
  end

  def pdf
    @factura = cargar_facturas.find { |f| f[:numero] == params[:numero].to_i }
    @cliente = cargar_clientes.find { |c| c[:id] == @factura[:cliente_id] }
    @impuestos = cargar_impuestos

    # Preparamos los items con sus detalles
    items = @factura[:items].map do |item|
      producto = @productos.find { |p| p[:codigo] == item[:producto_codigo] }
      impuesto = @impuestos.find { |i| i[:id] == item[:impuesto_id] }

      next unless producto

      subtotal = item[:precio_unitario].to_f * item[:cantidad].to_i
      impuesto_valor = impuesto ? (subtotal * (impuesto[:porcentaje].to_f / 100)) : 0

      {
        descripcion: producto[:nombre],
        cantidad: item[:cantidad],
        precio: item[:precio_unitario],
        impuesto_nombre: impuesto ? "#{impuesto[:nombre]} (#{impuesto[:porcentaje]}%)" : "Exento",
        impuesto_valor: impuesto_valor,
        subtotal: subtotal
      }
    end.compact # <- elimina elementos `nil`
    # Calculamos los totales de forma más segura
    subtotal = items.sum { |i| i[:subtotal] }
    total_impuestos = items.sum { |i| i[:impuesto_valor] }
    total = subtotal + total_impuestos

    respond_to do |format|
      format.pdf do
        pdf = Prawn::Document.new(page_size: "A4", page_layout: :portrait)

        # Encabezado
        pdf.text "FACTURA ##{@factura[:numero]}", size: 18, style: :bold, align: :center
        pdf.move_down 10
        pdf.text "Fecha: #{Time.now.strftime('%d/%m/%Y')}", align: :center
        pdf.stroke_horizontal_rule
        pdf.move_down 20

        # Información del cliente
        pdf.text "<b>Cliente:</b>", size: 12, style: :bold, inline_format: true
        pdf.move_down 5
        pdf.text "Nombre: #{@cliente[:nombre]}", inline_format: true
        pdf.text "Dirección: #{@cliente[:direccion]}", inline_format: true
        pdf.text "Teléfono: #{@cliente[:telefono]}", inline_format: true
        pdf.text "Email: #{@cliente[:email]}", inline_format: true
        pdf.move_down 20

        # Tabla de items
        header = [ "Producto", "Cant.", "Precio Unit.", "Impuesto", "Subtotal" ]
        item_rows = items.map do |item|
          [
            item[:descripcion],
            item[:cantidad].to_s,
            "$#{'%.2f' % item[:precio]}",
            item[:impuesto_nombre],
            "$#{'%.2f' % item[:subtotal]}"
          ]
        end

        pdf.table([ header ] + item_rows, header: true, width: pdf.bounds.width) do |table|
          table.row(0).font_style = :bold
          table.row(0).background_color = "f0f0f0"
          table.cells.borders = [ :bottom ]
          table.cells.padding = 5
        end

        # Totales
        pdf.move_down 30
        pdf.bounding_box([ pdf.bounds.width - 200, pdf.cursor ], width: 200) do
          pdf.text "<b>Subtotal:</b> $#{'%.2f' % subtotal}", inline_format: true, align: :right
          pdf.text "<b>Impuestos:</b> $#{'%.2f' % total_impuestos}", inline_format: true, align: :right
          pdf.move_down 5
          pdf.stroke_horizontal_rule
          pdf.text "<b>TOTAL:</b> $#{'%.2f' % total}", inline_format: true, align: :right, size: 14, style: :bold
        end

        send_data pdf.render,
                  filename: "factura_#{@factura[:numero]}.pdf",
                  type: "application/pdf",
                  disposition: "inline"
      end
    end
  rescue => e
    Rails.logger.error "Error al generar PDF: #{e.message}"
    redirect_to facturacion_index_path, alert: "Error al generar el PDF"
  end
  private

  def cargar_datos
    @productos = cargar_productos
    @clientes = cargar_clientes
    @impuestos = cargar_impuestos
  end

  def cargar_productos
    path = Rails.root.join("app", "data", "productos.json")
    File.exist?(path) ? JSON.parse(File.read(path), symbolize_names: true) : []
  end

  def cargar_clientes
    path = Rails.root.join("app", "data", "clientes.json")
    File.exist?(path) ? JSON.parse(File.read(path), symbolize_names: true) : []
  end

  def cargar_impuestos
    path = Rails.root.join("app", "data", "impuestos.json")
    File.exist?(path) ? JSON.parse(File.read(path), symbolize_names: true) : []
  end

  def cargar_facturas
    path = Rails.root.join("app", "data", "facturas.json")
    if File.exist?(path)
      facturas = JSON.parse(File.read(path), symbolize_names: true)
      # Asegurar que cada factura tenga items como array
      facturas.each do |factura|
        factura[:items] ||= []
      end
      facturas
    else
      []
    end
  end

  def guardar_facturas(facturas)
    path = Rails.root.join("app", "data", "facturas.json")
    File.write(path, JSON.pretty_generate(facturas))
  end

  def siguiente_numero_factura
    facturas = cargar_facturas
    facturas.empty? ? 1 : facturas.last[:numero].to_i + 1
  end

  def actualizar_stock_factura(factura)
    productos_path = Rails.root.join("app", "data", "productos.json")
    productos = cargar_productos
    historial_path = Rails.root.join("app", "data", "historial_stock.json")
    historial = File.exist?(historial_path) ? JSON.parse(File.read(historial_path)) : []

    factura.items.each do |item|
      producto = productos.find { |p| p[:codigo] == item.producto_codigo }
      if producto
        cantidad_anterior = producto[:stock].to_i
        producto[:stock] = cantidad_anterior - item.cantidad

        # Registrar en historial
        registro = HistorialStock.new(
          codigo_producto: item.producto_codigo,
          cambio: -item.cantidad,
          motivo: "Venta en factura #{factura.numero}"
        ).to_hash
        historial << registro
      end
    end

    File.write(productos_path, JSON.pretty_generate(productos))
    File.write(historial_path, JSON.pretty_generate(historial))
  end
end
