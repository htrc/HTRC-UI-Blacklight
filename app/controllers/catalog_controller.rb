# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController  

  include Blacklight::Catalog
  include BlacklightAdvancedSearch::ParseBasicQ
  
  configure_blacklight do |config|
    config.default_solr_params = { 
      #:qt => 'search',
      :qt => 'sharding',
      :rows => 10,
      :q => '*:*',
      :'q.alt' => '*:*',
      :facet => 'true',
      :'facet.mincount' => 1,
      :'facet.limit' => 20,
      :echoParams => 'all'
    }

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or 
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.default_document_solr_params = {
      :qt => 'sharding',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
     :fl => '*',
     :rows => 1,
     :q => '{!raw f=id v=$id}',
     :echoParams => 'all'
    }


    # solr field configuration for search results/index views
    config.index.show_link = 'title'
    config.index.record_display_type = 'format'

    # solr field configuration for document/show views
    config.show.html_title = 'title'
    config.show.heading = 'title'
    config.show.display_type = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.  
    config.add_facet_field 'format', :label => 'Format', :limit => true
    config.add_facet_field 'era', :label => 'Era', :limit => true
    config.add_facet_field 'publishDate', :label => 'Year', :limit => true
    config.add_facet_field 'topicStr', :label => 'Subject', :limit => true
    config.add_facet_field 'language', :label => 'Language', :limit => true
    config.add_facet_field 'htsource', :label => 'Source', :limit => true
    config.add_facet_field 'genreStr', :label => 'Original Format', :limit => true
    #config.add_facet_field 'topic', :label => 'Topic', :limit => 20 
    #config.add_facet_field 'language_facet', :label => 'Language', :limit => true 
    #config.add_facet_field 'lc_1letter_facet', :label => 'Call Number' 
    #config.add_facet_field 'subject_geo_facet', :label => 'Region' 
    #config.add_facet_field 'subject_era_facet', :label => 'Era'  

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.default_solr_params[:'facet.field'] = config.facet_fields.keys

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    #config.add_index_field 'title_display', :label => 'Title:' 
    #config.add_index_field 'title_vern_display', :label => 'Title:' 
    #config.add_index_field 'author_display', :label => 'Author:' 
    #config.add_index_field 'author_vern_display', :label => 'Author:' 
    #config.add_index_field 'format', :label => 'Format:' 
    #config.add_index_field 'language_facet', :label => 'Language:'
    #config.add_index_field 'published_display', :label => 'Published:'
    #config.add_index_field 'published_vern_display', :label => 'Published:'
    #config.add_index_field 'lc_callnum_display', :label => 'Call number:'
    config.add_index_field 'title', :label => 'Title:' 
    config.add_index_field 'author', :label => 'Author:' 
    #config.add_index_field 'Vauthor', :label => 'Author:'
    config.add_index_field 'format', :label => 'Format:' 
    config.add_index_field 'language', :label => 'Language:'
    config.add_index_field 'publishDate', :label => 'Published:'
    #config.add_index_field 'published_vern_display', :label => 'Published:'
    #config.add_index_field 'callnosort', :label => 'Call number:'
    #config.add_index_field 'ht_availability', :label =>'Availability:'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    #config.add_show_field 'title_display', :label => 'Title:' 
    #config.add_show_field 'title_vern_display', :label => 'Title:' 
    #config.add_show_field 'subtitle_display', :label => 'Subtitle:' 
    #config.add_show_field 'subtitle_vern_display', :label => 'Subtitle:' 
    #config.add_show_field 'author_display', :label => 'Author:' 
    #config.add_show_field 'author_vern_display', :label => 'Author:' 
    #config.add_show_field 'format', :label => 'Format:' 
    #config.add_show_field 'url_fulltext_display', :label => 'URL:'
    #config.add_show_field 'url_suppl_display', :label => 'More Information:'
    #config.add_show_field 'language_facet', :label => 'Language:'
    #config.add_show_field 'published_display', :label => 'Published:'
    #config.add_show_field 'published_vern_display', :label => 'Published:'
    #config.add_show_field 'lc_callnum_display', :label => 'Call number:'
    #config.add_show_field 'isbn_t', :label => 'ISBN:'

    #config.add_show_field 'title_topProper', :label => 'Title:' 
    config.add_show_field 'title', :label => 'Title:'
    #config.add_show_field 'Vtitle', :label => 'Title:' 
    config.add_show_field 'title_restProper', :label => 'Subtitle:' 
    #config.add_show_field 'subtitle_vern_display', :label => 'Subtitle:' 
    #config.add_show_field 'Vauthor', :label => 'Author:' 
    config.add_show_field 'author', :label => 'Author:' 
    config.add_show_field 'format', :label => 'Format:' 
    #config.add_show_field 'url_fulltext_display', :label => 'URL:'
    #config.add_show_field 'url_suppl_display', :label => 'More Information:'
    config.add_show_field 'language', :label => 'Language:'
    config.add_show_field 'publishDate', :label => 'Published:'
    #config.add_show_field 'published_vern_display', :label => 'Published:'
    config.add_show_field 'countryOfPubStr', :label => 'Country:'
    config.add_show_field 'callnumber', :label => 'Call number:'
    config.add_show_field 'isbn', :label => 'ISBN:'
    config.add_show_field 'oclc', :label => 'OCLC'
    config.add_show_field 'issn', :label => 'ISSN:'
    config.add_show_field 'htsource', :label=> 'Source:'
    config.add_show_field 'ht_availability', :label =>'Availability:'
    config.add_show_field 'id', :label =>'Volume ID:'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different. 

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise. 
    
    config.add_search_field 'all_fields', :label => 'Full Text'
    

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields. 
    
    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params. 
      field.solr_parameters = { :'spellcheck.dictionary' => 'title', :defType => 'dismax', :'q.alt' => '*:*' }
      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = { 
#        :qf => '$title_qf',
#        :pf => '$title_pf'
        :qf => 'title'
      }
    end
    
    config.add_search_field('author') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'author', :defType => 'dismax', :'q.alt' => '*:*' }
      field.solr_local_parameters = { 
#        :qf => '$author_qf',
#       :pf => '$author_pf'
        :qf => 'author'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as 
    # config[:default_solr_parameters][:qt], so isn't actually neccesary. 
    config.add_search_field('subject') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject', :defType => 'dismax', :'q.alt' => '*:*' }
      field.solr_local_parameters = { 
#        :qf => '$subject_qf',
#        :pf => '$subject_pf'
        :qf => 'topic'
      }
    end

    config.add_search_field('publishDate') do |field|
      field.solr_parameters = { :defType => 'dismax', :'q.alt' => '*:*' }
      field.include_in_simple_select = false
      field.solr_local_parameters = {
        :qf => 'publishDateTrie'
      }
    end
    
    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, titleSort asc', :label => 'relevance'
    #config.add_sort_field 'publishDate desc, title asc', :label => 'year'
    #config.add_sort_field 'callnosort asc, titleSort asc', :label => 'call number'
    config.add_sort_field 'titleSort asc', :label => 'title'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5
  end



end 
