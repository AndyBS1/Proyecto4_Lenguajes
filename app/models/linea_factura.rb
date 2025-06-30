class LineaFactura
  attr_accessor :codigo_producto, :cantidad, :precio_unitario

  def initialize(codigo_producto:, cantidad:, precio_unitario:)
    @codigo_producto = codigo_producto
    @cantidad = cantidad.to_i
    @precio_unitario = precio_unitario.to_f
  end

  def subtotal
    @cantidad * @precio_unitario
  end

  def to_hash
    {
      codigo_producto: @codigo_producto,
      cantidad: @cantidad,
      precio_unitario: @precio_unitario,
      subtotal: subtotal
    }
  end
end
