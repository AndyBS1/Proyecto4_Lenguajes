class HistorialStock
  attr_reader :codigo_producto, :cambio, :motivo, :fecha

  def initialize(codigo_producto:, cambio:, motivo: nil)
    @codigo_producto = codigo_producto
    @cambio = cambio.to_i
    @motivo = motivo || "Ajuste en el stock"
    @fecha = Time.now
  end

  def to_hash
    {
      codigo_producto: @codigo_producto,
      cambio: @cambio,
      motivo: @motivo,
      fecha: @fecha.strftime("%d-%m-%Y %H:%M:%S")
    }
  end
end
