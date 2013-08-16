module OffersHelper
  require 'curb'
  require 'net/http'
  require 'net/http/post/multipart'
  
  def create_url(id, click_variables = [])
    offer_domain = 'http://offerstest.c44959.blueboxgrid.com:3000'
    query = click_variables.inject("") { |acc, e| acc + "&#{ e }={#{ e }}" }
    "#{ offer_domain }/offers/show?id=#{ id }#{ query }"
  end
  
  def success?(response_hash)
    response_hash['status'] == 1
  end

  def submit(terms, type = :get, file = nil)
    base_uri = 'https://api.hasoffers.com/Api/json?'
    terms.update(:Format => 'json',
             :Service => 'HasOffers',
             :Version => 2,
             :NetworkId => 'crystalcommerce1',
             :NetworkToken => 'NETQ3JIyJB4p5SGZcdenYq8uy6kiaP')
    uri = URI.parse(base_uri + terms.to_query)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.set_debug_output $stderr
    if type == :get
      raw_request = Net::HTTP::Get.new(uri.request_uri)
    elsif type == :multipart_post
      upload = UploadIO.new file, file.content_type, file.original_filename
      raw_request = Net::HTTP::Post::Multipart.new uri.request_uri,
        file.original_filename => upload
    end
    response = http.request(raw_request)
    (JSON.parse response.body)['response']
  end
end
