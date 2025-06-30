class Cliente
  attr_accessor :id, :nombre, :direccion, :telefono, :email

  def initialize(id:, nombre:, direccion:, telefono: nil, email: nil)
    @id = id
    @nombre = nombre.strip
    @direccion = direccion.strip
    @telefono = telefono
    @email = email
  end

  def to_hash
    {
      id: @id,
      nombre: @nombre,
      direccion: @direccion,
      telefono: @telefono,
      email: @email
    }
  end

  def valido?
    return false if nombre.empty? || direccion.empty?
    return false if email && !email.match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
    true
  end
end
