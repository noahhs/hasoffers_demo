class AddPercentsToOffer < ActiveRecord::Migration
  def change
    add_column :offers, :rps, :float
    add_column :offers, :cps, :float
  end
end
