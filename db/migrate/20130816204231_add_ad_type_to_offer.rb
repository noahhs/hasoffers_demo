class AddAdTypeToOffer < ActiveRecord::Migration
  def change
    add_column :offers, :ad_type, :string
  end
end
