class ProductsController < ApplicationController
  def create
    @product = Product.new
    @product.name = name = params[:name]
    @product.save
    flash[:notice] = "Product created! ID: #{ @product.id }, name: #{ name }"
  end
end
