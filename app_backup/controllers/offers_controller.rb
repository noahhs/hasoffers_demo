class OffersController < ApplicationController
  def show
    @affiliate = nil
    @id = params[:id]
    @offer = Offer.find_by_id @id
    @product = Product.find_by_id @offer.product_id
    @click_data = @offer.click_variables.inject({}) do |acc, var|
      acc[var] = params[var]
    end
    @hasoffers_data = @order.hasoffers_data
    #render :file => "offer_#{@id}.html.haml"
  end

  def convert
  end

  def new
    @offer = Offer.new
    render "new"
  end

  def create
    @offer = Offer.new(params[:offer])
    @offer.create

  end

  def refresh
    @offer.refresh
      
    redirect_to :show
  end

end
