class Offer < ActiveRecord::Base
  require 'net/http'
  include OffersHelper
  
  attr_accessor :hasoffers_data, :click_variables,
                :name, :product_id, :description

  #def initialize(*params)
  #  params.each do |key, value|
  #    self.send key = value
  #  end
  #end
  
  def create
    click_variables = [:offer_id]
    domain = 'http://offerstest.c44959.blueboxgrid.com:3000'
    query = querify_array(click_variables.reject {|v| v == :offer_id })

    offer_url = "#{ domain }/offers/show?id={offer_id}#{ query }"

    terms = { :Method => 'create',
              :data => { :name => name, 
                         :description => description,
                         :offer_url => offer_url,
                         :preview_url => 'temp',
                         :expiration_date => '2025-01-01' }}
    response = submit terms
    if success?(response)
      self.id = ( self.hasoffers_data = response['data']['Offer'] )['id'].to_i
      save
      nil
    else
      response['errorMessage']
    end
  end
  
  private

    def submit(terms)
      base_uri = 'https://api.hasoffers.com/Api/json?'
      terms.update(:Format => 'json',
               :Target => 'Offer',
               :Service => 'HasOffers',
               :Version => 2,
               :NetworkId => 'crystalcommerce1',
               :NetworkToken => 'NETQ3JIyJB4p5SGZcdenYq8uy6kiaP')
      
      #uri = URI.parse(base_uri + querify_hash(terms))
      uri = URI.parse(base_uri + terms.to_query)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      raw_request = Net::HTTP::Get.new(uri.request_uri)
      (JSON.parse http.request(raw_request).body)['response']
    end

end
