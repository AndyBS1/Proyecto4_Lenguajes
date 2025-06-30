class Impuesto
  attr_accessor :id, :nombre, :porcentaje

  def initialize(id:, nombre:, porcentaje:)
    @id = id
    @nombre = nombre.strip
    @porcentaje = porcentaje.to_f
  end

  def to_hash
    {
      id: @id,
      nombre: @nombre,
      porcentaje: @porcentaje
    }
  end

  def valido?
    return false if nombre.empty?
    return false unless porcentaje.is_a?(Numeric) && porcentaje >= 0
    true
  end
end
