class AddProductIdToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :product_id, :integer
  end
end
