require "test_helper"

class InventarioControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get inventario_index_url
    assert_response :success
  end

  test "should get agregar" do
    get inventario_agregar_url
    assert_response :success
  end

  test "should get editar" do
    get inventario_editar_url
    assert_response :success
  end
end
