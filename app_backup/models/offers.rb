class Offer < ActiveRecord::Base
  require 'net/http'
  
  attr_accessor :hasoffers_data, :click_variables,
                :name, :product_id, :description

  #def initialize(*params)
  #  params.each do |key, value|
  #    self.send key = value
  #  end
  #end
  
  def initialize
  end

  def create
    require 'pry'
    binding.pry
    click_variables = [:offer_id]
    domain = 'http://offerstest.c44959.blueboxgrid.com:3000'
    query = querify_array(click_variables.reject {|v| v == :offer_id })
    offer_url = "#{ domain }/offers/show?id={offer_id}#{ query }"
    terms = { :Method => 'create',
              :name => name, 
              :description => description,
              :offer_url => offer_url }

    response = submit terms
    hasoffers_data = response[:data]
    if response.success?
      save
      flash[:notice] = "Success! ID: #{ id }"
    else
      flash[:error] = "Request failed! #{ response[:errors] }"
    end
  end
  
  private

    def submit(terms)
      require 'pry'
      binding.pry
      base_uri = 'https://api.hasoffers.com/Api/json?Format=json'
      terms.update = { :Target => 'Offer',
               :Service => 'HasOffers',
               :Version => 2
               :NetworkId => 'crystalcommerce1',
               :NetworkToken => 'NETQ3JIyJB4p5SGZcdenYq8uy6kiaP' }
      
      uri = URI.parse(base_uri + querify_hash(terms))
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      raw_request = Net::HTTP::Get.new(uri.request_uri)
      JSON.parse http.request(raw_request).body
    end

end
