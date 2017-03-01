class Store < ActiveRecord::Base
  self.table_name = "st"
  self.primary_key = "sid"
  has_many :ticket_items
end
