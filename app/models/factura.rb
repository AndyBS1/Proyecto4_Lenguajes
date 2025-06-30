class Factura
  attr_accessor :numero, :fecha, :cliente_id, :items, :estado

  def initialize(numero:, fecha: Time.now, cliente_id:, items: [], estado: "pendiente")
    @numero = numero
    @fecha = fecha
    @cliente_id = cliente_id
    @items = items || []
    @estado = estado
  end

  def agregar_item(item)
    @items << item
  end

  def subtotal
    @items.sum(&:subtotal)
  end

  def total_impuestos(impuestos_lista)
    @items.sum do |item|
      next 0 unless item.impuesto_id
      impuesto = impuestos_lista.find { |i| i[:id] == item.impuesto_id }
      item.subtotal * (impuesto[:porcentaje].to_f / 100.0)
    end
  end

def total(impuestos_lista)
  subtotal + total_impuestos(impuestos_lista)
end

  def total
    subtotal + total_impuestos
  end

  def to_hash
    {
      numero: @numero,
      fecha: @fecha.strftime("%Y-%m-%d %H:%M:%S"),
      cliente_id: @cliente_id,
      items: @items.map(&:to_hash),
      estado: @estado
    }
  end
end
