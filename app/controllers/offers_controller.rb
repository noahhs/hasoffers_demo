class OffersController < ApplicationController
  include OffersHelper
  
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
  
  #temp
  def check
    terms = { :Method => 'findById',
              :Target => 'OfferFile',
              :id => 20 }
    response = submit terms
  end
  def new
    @offer = Offer.new
  end

  def create
    offer_attributes = params[:offer].to_h.reject {|e| e == 'offer_file' }
    @offer = Offer.new(offer_attributes)
    if (error_message = @offer.create).present?
      flash[:error] = "Request failed! #{ error_message }"
    else
      offer_file = params[:offer][:offer_file]
      if (error_message = @offer.create_file offer_file).present?
        flash[:error] = "Request failed! #{ error_message }"
      else 
        flash[:notice] = "Success! Offer ID: #{ @offer.id }, " \
                       + "creative file ID: #{ @offer.creative_file_id }"
      end
    end
    render 'new'
  end

  def refresh
    @offer.refresh
      
    redirect_to :show
  end

end
