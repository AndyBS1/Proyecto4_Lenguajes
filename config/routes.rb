Rails.application.routes.draw do
  get "menu/index"
  get "facturas/index"
  get "facturas/nueva"
  get "facturas/generar"
  get "inventario/index"
  get "inventario/agregar"
  get "inventario/editar", to: "inventario#editar"
  get "inventario/historial"
  get "/facturas/pdf", to: "facturas#pdf"
  get "/facturacion", to: "facturacion#index", as: "facturacion_index"
  get "/facturacion/nueva", to: "facturacion#nueva", as: "facturacion_nueva"
  post "/facturacion/crear", to: "facturacion#crear", as: "facturacion_crear"
  get "/facturacion/:numero", to: "facturacion#mostrar", as: "facturacion_mostrar"
  get "/facturacion/:numero/pdf", to: "facturacion#pdf", as: "facturacion_pdf"
  delete "facturacion/eliminar", to: "facturacion#eliminar", as: "facturacion_eliminar"
  # Rutas para clientes
  get "/clientes", to: "clientes#index", as: "clientes_index"
  get "/clientes/nuevo", to: "clientes#nuevo", as: "clientes_nuevo"
  post "/clientes/crear", to: "clientes#crear", as: "clientes_crear"
  # Rutas para impuestos
  get "/impuestos", to: "impuestos#index", as: "impuestos_index"
  get "/impuestos/nuevo", to: "impuestos#nuevo", as: "impuestos_nuevo"
  post "/impuestos/crear", to: "impuestos#crear", as: "impuestos_crear"
  # Ruta de Post
  post "inventario/crear", to: "inventario#crear"
  post "/inventario/actualizar", to: "inventario#actualizar"

  # Update
  patch "/inventario/:codigo", to: "inventario#actualizar", as: :actualizar_producto
  patch "/inventario/historial/actualizar_motivo", to: "inventario#actualizar_motivo", as: "actualizar_motivo"

  # Delete
  delete "/inventario/eliminar", to: "inventario#eliminar", as: "eliminar_producto"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "menu#index"
end
