class Offer < ActiveRecord::Base
  include OffersHelper
  
  serialize :click_variables
  serialize :hasoffers_data

  def self.get id
    offer = Offer.find_by_id id
    if !offer.nil?
      {:offer => offer}
    else
      o = Offer.new
      response = o.pull_missing(id)
      if !o.success? response
        response
      else
        {:offer => Offer.new.update_from_remote(response)}
      end
    end
  end

  def pull_missing id
    terms = { :Method => 'findById',
              :Target => 'OfferFile',
              :id => id }
    submit terms
  end

  def create
    self.click_variables = ['affiliate_id', 'affiliate_name']
    if ad_type == 'form_1'
      self.click_variables << 'custom_var_1'<< 'custom_var_2'
    end
    self.cps = rps #temp for simplicity
    terms = { :Method => 'create',
              :Target => 'Offer',
              :data => { :name => name, 
                         :description => description,
                         :offer_url => 'temp',
                         :preview_url => 'temp',
                         :status => 'active',
                         :show_custom_variables => 1,
                         :expiration_date => '2025-01-01',
                         :revenue_type => 'cpa_percentage',
                         :payout_type => 'cpa_percentage',
                         :max_percent_payout => cps,
                         :percent_payout => rps }}
    response = submit terms
    if !success? response
      response
    else
      id = response['data']['Offer']['id'].to_i
      # update urls based on received id
      terms = { :Method => 'update',
                :Target => 'Offer',
                :id => id,
                :data => { :offer_url => create_url(id, click_variables),
                           :preview_url => create_url(id) }}
      response = submit terms
      if !success? response
        response
      else
        hod = response['data']['Offer']
        # why doesn't update_attributes work?
        self.hasoffers_data = hod
        self.id = id
        self.rps = hod['percent_payout']
        self.cps = hod['max_percent_payout']
        save
        { :offer => self }
      end
    end
  end

  def update_from_remote response

  end

  def create_file(file)
    terms = { :Method => 'create',
              :Target => 'OfferFile',
              :filename => file.original_filename,
              :data => { :offer_id => id, 
		         :display => file.original_filename,
                         :type => 'image banner' }}
    response = submit terms, :multipart_post, file
    if !success? response
      response
    else
      response['data']['OfferFile']
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
