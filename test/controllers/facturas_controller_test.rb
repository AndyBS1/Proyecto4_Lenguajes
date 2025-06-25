require "test_helper"

class FacturasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get facturas_index_url
    assert_response :success
  end

  test "should get nueva" do
    get facturas_nueva_url
    assert_response :success
  end

  test "should get generar" do
    get facturas_generar_url
    assert_response :success
  end
end
