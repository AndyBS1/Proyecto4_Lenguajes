class ImpuestosController < ApplicationController
  def index
    @impuestos = cargar_impuestos
  end

  def nuevo
    @impuesto = Impuesto.new(id: SecureRandom.uuid, nombre: "", porcentaje: 0)
  end

  def crear
    impuesto = Impuesto.new(
      id: SecureRandom.uuid,
      nombre: params[:nombre],
      porcentaje: params[:porcentaje]
    )

    unless impuesto.valido?
      flash[:alert] = "Por favor complete los campos requeridos correctamente."
      redirect_to impuestos_nuevo_path and return
    end

    impuestos = cargar_impuestos
    impuestos << impuesto.to_hash

    guardar_impuestos(impuestos)

    redirect_to impuestos_index_path, notice: "Impuesto creado correctamente"
  end

  private

  def cargar_impuestos
    path = Rails.root.join("app", "data", "impuestos.json")
    File.exist?(path) ? JSON.parse(File.read(path), symbolize_names: true) : []
  end

  def guardar_impuestos(impuestos)
    path = Rails.root.join("app", "data", "impuestos.json")
    File.write(path, JSON.pretty_generate(impuestos))
  end
end
