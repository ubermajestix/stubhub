module Stubhub
  class Geo
    include Stubhub::APIMapper

    key :active,                            Integer, :predicate => proc{|r| r == 1 }
    key :ancestor_description,              String
    key :ancestor_geo_ids,                  Array,   :split_on => " ", :map => proc(&:to_i)
    key :ancestor_keywords,                 String
    key :category_search_keywords,          String
    key :category_type,                     String
    key :channel,                           String
    key :channel_id,                        Integer
    key :channel_url_path,                  String
    key :date_last_indexed,                 Date
    key :date_added,                        Date
    key :date_last_modified,                Date
    key :deleted,                           Integer, :predicate => proc{|r| r == 1 }
    key :desc_sort,                         String
    key :description,                       String
    key :do_not_display_flag,               Integer, :predicate => proc{|r| r == 1 }
    key :event_types,                       Array
    key :full_description,                  String
    key :geo_id,                            Integer
    key :geography_meta_description,        String
    key :hidden,                            Integer, :predicate => proc{|r| r == 1 }
    key :home_team,                         String
    key :id,                                Integer
    key :is_valid_category_search_result,   Integer, :predicate => proc{|r| r == 1 }
    key :keywords,                          Array,   :split_on => ","
    key :leaf,                              String
    key :locale,                            String
    key :locale_description,                String
    key :meta_description,                  String
    key :name_primary,                      String
    key :name_secondary,                    String
    key :parent_id,                         Integer
    key :season_venue_flag,                 String
    key :seo_description,                   String
    key :seo_title,                         String
    key :stubhub_document_id,               String
    key :stubhub_document_type,             String
    key :three_levels_up_ids,               String
    key :title,                             String
    key :urlpath,                           String
    key :urlpathid,                         Integer
    key :venue_detail_url_path,             String
    key :venue_detail_url_path_id,          Integer

    def self.find_by_geo_id(geo_id, options = {})
      params = {"stubhubDocumentType" => "#{self.demodulize.downcase}",
                "geoId" => "#{geo_id}"}
      Client.make_request(Geo, params, options)
    end

    # rough matching. i.e. "San Francisco" will match "San Diego" due to the "+San+"
    def self.find_by_locale(locale, options = {})
      params = {"stubhubDocumentType" => "#{self.demodulize.downcase}",
                "localeDescription" => "#{URI::escape(locale)}"}
      Client.make_request(Geo, params, options)
    end

    def self.search(search_query, options = {})
      search_query = URI.escape(search_query)
      params = {"stubhubDocumentType" => "#{self.demodulize.downcase}",
                "description" => "#{search_query}"}
      Client.make_request(Geo, params, options)
    end

    def events(options = {})
      params = {"stubhubDocumentType" => "event",
                "ancestorGeoIds" => "#{self.geoId}"}
      Client.make_request(Event, params, options)
    end
  end
end
