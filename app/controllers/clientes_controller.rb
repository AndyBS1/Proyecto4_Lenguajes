class ClientesController < ApplicationController
  def index
    @clientes = cargar_clientes
  end

  def nuevo
    @cliente = Cliente.new(id: SecureRandom.uuid, nombre: "", direccion: "")
  end

  def crear
    cliente = Cliente.new(
      id: SecureRandom.uuid,
      nombre: params[:nombre],
      direccion: params[:direccion],
      telefono: params[:telefono],
      email: params[:email]
    )

    unless cliente.valido?
      flash[:alert] = "Por favor complete los campos requeridos correctamente."
      redirect_to clientes_nuevo_path and return
    end

    clientes = cargar_clientes
    clientes << cliente.to_hash

    guardar_clientes(clientes)

    redirect_to clientes_index_path, notice: "Cliente creado correctamente"
  end

  private

  def cargar_clientes
    path = Rails.root.join("app", "data", "clientes.json")
    File.exist?(path) ? JSON.parse(File.read(path), symbolize_names: true) : []
  end

  def guardar_clientes(clientes)
    path = Rails.root.join("app", "data", "clientes.json")
    File.write(path, JSON.pretty_generate(clientes))
  end
end
