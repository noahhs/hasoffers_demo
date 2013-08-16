class OffersController < ApplicationController
  include OffersHelper
  
  def show
    @affiliate_id = params[:affiliate_id]
    @id = params[:id]
    @offer = Offer.find_by_id @id
    @hasoffers_data = @offer.hasoffers_data
    @product = Product.find_by_id @offer.product_id
  end

  def convert
  end
  
  #temp, just for debugging purposes
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
        #if (error_message = @offer.create_tracking).present?
        #  flash[:error] = "Request failed! #{ error_message }"
        #else
          flash[:notice] = "Success! Offer ID: #{ @offer.id }, " \
                         + "creative file ID: #{ @offer.creative_file_id }"
        #end
      end
    end
    render 'new'
  end

  def refresh
    @offer.refresh
      
    redirect_to :show
  end

end
