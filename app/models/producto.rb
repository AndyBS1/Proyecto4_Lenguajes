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

  def valido?
    # El código debe ser una letra mayuscula con 3 números. (Ej: T001)
    return false unless codigo =~ /\A[A-Z]\d{3}\z/

    # Máximo 64 caracteres
    return false if nombre.nil? || nombre.strip.length > 64

    # Debe ser un número mayor a 0
    return false unless es_numero?(precio) && precio.to_f > 0

    # Debe ser entero
    return false unless es_entero?(stock) && stock.to_i >= 0

    true
  end

  private

  def es_numero?(num)
    true if Float(num) rescue false
  end

  def es_entero?(num)
    true if Integer(num) rescue false
  end
end
