json.array!(@sale) do |sale|
  json.extract! counter_commission, :id, :id, :date, :sid, :line, :part, :sell, :qtysold, :created_at, :updated_at
  json.url sale_url(sale, format: :json)
end
