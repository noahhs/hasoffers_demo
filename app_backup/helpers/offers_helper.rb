module OffersHelper
  def querify_hash(hash)
    hash.inject("") { |acc, (key, value)| acc + "&#{ key }=#{ value }" }
  end

  def querify_array(array)
    array.inject("") { |acc, e| acc + "&#{ e }={#{ e }}" }
  end
end
