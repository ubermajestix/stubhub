require 'spec_helper'
GEO_ID = 81989
LOCALE = "SF Bay Area"

module Stubhub
  describe Geo do
    before :each do
      VCR.insert_cassette 'geo' do
      end
    end
    after :each do
      VCR.eject_cassette
    end

    let(:geo){ Geo.find_by_geo_id(GEO_ID) }

    context "predicate methods" do
      it "should be active" do
        geo.should be_active
      end

      it "should not be hidden" do
        geo.should_not be_hidden
      end
    end

    context "integer methods" do
      it "id" do
        geo.id.should be_kind_of Integer
        geo.id.should eq 81989
      end
    end

    context "array methods" do
      it "should split ancestor_geo_ids into integers" do
        geo.ancestor_geo_ids.should be_kind_of Array
        geo.ancestor_geo_ids.first.should be_kind_of Integer
      end
      
      it "should split keywords on commas" do
        geo.keywords.should be_kind_of Array
        geo.keywords.first.should eq "Bob Hope Theatre seating chart"
      end
    end

    context ".find_by_geo_id" do
      it "finds the geo with geoId #{GEO_ID}" do
        geo = Geo.find_by_geo_id(GEO_ID)
        geo.id.should eq(GEO_ID)
      end
    end

    context ".find_by_locale" do
      it "finds the geos within the locale #{LOCALE}" do
        geos = Geo.find_by_locale(LOCALE)
        geos.length.should be >= 1
      end

      it "should raise no method error" do
        geos = Geo.find_by_locale(LOCALE).first
        expect{ geos.not_a_method }.to raise_error NoMethodError
      end
    end

    context ".search" do
      it "peforms a geo search for the keyword" do
        geos = Geo.search("Bob Hope")
        geos.length.should be >= 1
      end
    end

  end
end
