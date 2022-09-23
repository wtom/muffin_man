RSpec.describe MuffinMan::FulfillmentInbound::V0 do
  before do
    stub_request_access_token
  end

  let(:country_code) { "US" }
  let(:sku_list) { ["SD-ABC-12345"] }

  subject(:fba_inbound_client) { described_class.new(credentials) }

  describe "get_prep_instructions" do
    before { stub_get_prep_instructions }

    it "makes a request to get prep instructions for a SKU/country" do
      expect(fba_inbound_client.get_prep_instructions(country_code, seller_sku_list: sku_list).response_code).to eq(200)
      expect(JSON.parse(fba_inbound_client.get_prep_instructions(country_code, seller_sku_list: sku_list).body).dig("payload", "SKUPrepInstructionsList").first["SellerSKU"]).to eq(sku_list.first)
    end
  end

  describe "create_inbound_shipment_plan" do
    before { stub_create_inbound_shipment_plan }
    let(:address) do
      {
        "Name"=>"The Muffin Man",
        "AddressLine1"=>"12345 Drury Lane",
        "AddressLine2"=>nil,
        "City"=>"CandyLand",
        "DistrictOrCounty"=>nil,
        "StateOrProvinceCode"=>"CL",
        "CountryCode"=>"US",
        "PostalCode"=>"12345"
      }
    end
    let(:label_prep_preference) { "SELLER_LABEL" }
    let(:inbound_shipment_plan_request_items) do
      [
        {
          "SellerSKU"=>"SD-ABC-123456",
          "ASIN"=>"B123456JKL",
          "Quantity"=>1,
          "QuantityInCase"=>nil,
          "PrepDetailsList"=>[],
          "Condition"=>"NewItem",
        }
      ]
    end

    it "makes a request to create an inbound shipment plan" do
      response = fba_inbound_client.create_inbound_shipment_plan(address, label_prep_preference, inbound_shipment_plan_request_items)
      expect(response.response_code).to eq(200)
      expect(JSON.parse(response.body).dig("payload", "InboundShipmentPlans").first["ShipmentId"]).to eq('FBA16WN8GFP1')
    end
  end
end
