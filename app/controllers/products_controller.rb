class ProductsController < ApplicationController
  def create
    @name = params[:name]
    @product = Product.new @name
    @product.save
    flash[:notice] = "Product created! ID: #{ @product.id }"
  end
end
