Advertiser::Application.routes.draw do
  get ':controller/:action'#will this allow us as many params as we want?
  get ':controller/:action/:id'

  #don't see why i need this
  #get '/offers/new', to: 'offers#new'
  resources :offers, :path => 'offers'
end
