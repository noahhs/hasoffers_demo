class AddFieldsToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :name, :string
    add_column :offers, :description, :string
    add_column :offers, :click_variables, :text
    add_column :offers, :hasoffers_data, :text
  end
end
