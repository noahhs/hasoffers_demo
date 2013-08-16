class Offer < ActiveRecord::Base
  include OffersHelper
  require 'rest-client'
  
  #attr_accessor :hasoffers_data, :click_variables,
  #              :name, :product_id, :description,
  attr_accessor             :creative_file_id  #temp?

  def create
    terms = { :Method => 'create',
              :Target => 'Offer',
              :data => { :name => name, 
                         :description => description,
                         :offer_url => 'temp',
                         :preview_url => 'temp',
                         :status => 'active',
                         :expiration_date => '2025-01-01' }}
    response = submit terms
    if success? response
      
      self.id = response['data']['Offer']['id'].to_i
      terms = { :Method => 'update',
                :Target => 'Offer',
                :id => id,
                :data => { :offer_url => create_url(id, [:affiliate_id]),
                           :preview_url => create_url(id) }}
      response = submit terms
      if success? response
        self.hasoffers_data = response['data']['Offer'].to_json
        s = save
        nil
      else
        response['errorMessage']
      end
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
    if success? response
      self.creative_file_id = response['data']['OfferFile']['id'].to_i
      #no save--We're not keeping this
      ##save
      nil
    else
      response['errorMessage']
    end
  end

  # Works, but don't actually need it, as it turns out.
  def create_tracking
    terms = { :Method => 'generateTrackingLink',
              :Target => 'Offer',
              :offer_id => id,
              :affiliate_id => 1004 }
    response = submit terms, :get
    response[:errorMessage] unless success? response
  end
end
