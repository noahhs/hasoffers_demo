module OffersHelper
  def querify_array(array)
    array.inject("") { |acc, e| acc + "&#{ e }={#{ e }}" }
  end
  
  def success?(response_hash)
    response_hash['status'] == 1
  end
end
