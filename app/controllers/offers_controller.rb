class OffersController < ApplicationController
  include OffersHelper
  
  def show
    on_success_of Offer.get(params[:id]) do |response|
      @offer = response[:offer]
      @hasoffers_data = @offer.hasoffers_data
      @product = Product.find_by_id @offer.product_id
      @click_data = @offer.click_variables.inject({}) do |acc, cvar|
        acc[cvar] = params[cvar]; acc
      end
    end
    @affiliate_id = params[:affiliate_id]
    @default_sale = 20
    @offer ||= Offer.new
  end

  def convert
    on_success_of Offer.get(params[:id]) do |response|
      @offer = response[:offer]
      terms = { :Target => 'Conversion',
                :Method  => 'create',
                :data => { :offer_id => @offer.id,
                   :affiliate_id => params[:affiliate_id],
                   :sale_amount => params[:amount],
                   :payout => @offer.cps/100 * params[:amount].to_f,
                   :revenue => @offer.rps/100 * params[:amount].to_f }}
      on_success_of(submit terms) do |response|
        id = response['data']['Conversion']['id']
        flash[:notice] = "Success! Conversion id: " << id
      end
    end
    @offer ||= Offer.new
  end
  
  #temp, just for debugging purposes
  def check
    terms = { :Method => 'findById',
              :Target => 'OfferFile',
              :id => params[:id] }
    response = submit terms
  end
  
  def new
    @offer = Offer.new
  end

  def create
    @offer = Offer.new(params[:offer].to_h.reject {|e| e == 'offer_file' })
    on_success_of @offer.create do |response|
      offer_id = response[:offer].id
      offer_file = params[:offer][:offer_file]
      on_success_of @offer.create_file(offer_file) do |response|
        file_id = response['id']
        flash[:notice] = "Success! Offer ID: #{ offer_id }, " \
          + "creative file ID: #{ file_id }"
      end
    end
    render 'new'
  end

  private

    def on_success_of api_response, &success_block
      if (errors = api_response['errors']).present?
        flash[:error] = ""
        errors.each do |e|
          flash[:error] << "\n" << "Request failed! " \
          + "#{e['publicMessage']} #{e['err_msg']}: #{e['attribute_name']}"
        end
      else
        success_block.call(api_response)
      end
    end
end
