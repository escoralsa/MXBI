json.array!(@sales) do |sale|
  json.extract! sale, :id, :id, :date, :sid, :line, :part, :sell, :qtysold
  json.url sale_url(sale, format: :json)
end
