class FacturaItem
  attr_accessor :producto_codigo, :cantidad, :precio_unitario, :impuesto_id

  def initialize(producto_codigo:, cantidad:, precio_unitario:, impuesto_id: nil)
    @producto_codigo = producto_codigo
    @cantidad = cantidad.to_i
    @precio_unitario = precio_unitario.to_f
    @impuesto_id = impuesto_id
  end

  def subtotal
    @precio_unitario * @cantidad
  end

  def to_hash
    {
      producto_codigo: @producto_codigo,
      cantidad: @cantidad,
      precio_unitario: @precio_unitario,
      impuesto_id: @impuesto_id
    }
  end
end
