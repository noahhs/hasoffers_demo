class Offer < ActiveRecord::Base
  include OffersHelper
  require 'rest-client'
  
  attr_accessor :hasoffers_data, :click_variables,
                :name, :product_id, :description,
                :creative_file_id  #temp?

  def create
    click_variables = [:offer_id]
    offer_domain = 'http://offerstest.c44959.blueboxgrid.com:3000'
    query = querify_array(click_variables.reject {|v| v == :offer_id })
    offer_url = "#{ offer_domain }/offers/show?id={offer_id}#{ query }"

    terms = { :Method => 'create',
              :Target => 'Offer',
              :data => { :name => name, 
                         :description => description,
                         :offer_url => offer_url,
                         :preview_url => 'temp',
                         :expiration_date => '2025-01-01' }}
    response = submit terms
    if success? response
      self.id = ( self.hasoffers_data = response['data']['Offer'] )['id'].to_i
      save
      nil
    else
      response['errorMessage']
    end
  end

  def create_file(file)
    terms = { :Method => 'create',
              :Target => 'OfferFile',
            #  :filename => file.original_filename,
              :data => { :offer_id => id, 
		         :display => file.original_filename,
                         :type => 'image banner' },
		 :filename => file.original_filename }
    response = submit terms, :multipart_post, file
    #base_uri = 'https://api.hasoffers.com/Api/json?'
    #terms.update(:Format => 'json',
    #         :Service => 'HasOffers',
    #         :Version => 2,
    #         :NetworkId => 'crystalcommerce1',
    #         :NetworkToken => 'NETQ3JIyJB4p5SGZcdenYq8uy6kiaP')
    #response = RestClient.post :file
    if success? response
      self.creative_file_id = response['data']['OfferFile']['id'].to_i
      save
      nil
    else
      response['errorMessage']
    end
  end
end
