class Producto
  attr_accessor :codigo, :nombre, :precio, :stock

  def initialize(codigo:, nombre:, precio:, stock:)
    @codigo = codigo
    @nombre = nombre
    @precio = precio.to_f
    @stock = stock.to_i
  end

  def to_hash
    {
      codigo: @codigo,
      nombre: @nombre,
      precio: @precio,
      stock: @stock
    }
  end

  def stock_bajo?
    @stock <= 3
  end
end
