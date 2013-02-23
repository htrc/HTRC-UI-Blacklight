# -*- encoding : utf-8 -*-

#
# Controller for "Select All" checkbox
#
class SelectAllController < ApplicationController
  include Blacklight::Configurable
  include Blacklight::SolrHelper

  copy_blacklight_config_from(CatalogController)

  helper CatalogHelper

  # Add all documents from the current query to the set of selected documents
  # /select_all handler: add all documents from the current query to the set of 
  # selected documents
  def index

    # Initialize stored document ids, if empty
    if (session[:folder_document_ids].nil?)
        session[:folder_document_ids] = Array.new 
    end

    # Get the current list of stored document ids
    selected = session[:folder_document_ids]

    # Get the list of ids for the current query
    ids = get_ids_for_query()
 
    # Add any missing ids to the list of selected document ids
    for id in ids
       if (!selected.include?(id))
          #logger.debug "Adding #{id} to selected items"
          session[:folder_document_ids] << id
       end
    end

    # JSON response for JQuery checkbox includes the total number ids
    respond_to do |format|
        format.json { render :json => { :count => session[:folder_document_ids].length } }
    end

  end


  # Clear all selected IDs
  def clear

    # Get the list of currently selected ids
    selected = session[:folder_document_ids]

    respond_to do |format|
        format.json { render :json => { :count => session[:folder_document_ids].length  } }
    end

  end

  # Run the current query and get only the ids from solr
  def get_ids_for_query

    ids = Array.new

    # Total number of documents from current query
    total_docs = session[:search][:total]

    # Construct Solr query
    solr_params = Hash.new
    solr_params[:fl] = "id"
    solr_params[:rows] = total_docs
    #solr_params[:rows] = 1000 # Limit to 1000 for now
    solr_params[:start] = "0"

    @response, @documents = get_search_results(session[:search], solr_params)

    start = @response.response[:start]
    num_found = @response.response[:numFound]
    
    # Populate the list of ids
    for doc in @response.response[:docs]
       ids << doc[:id]
    end
 
    return ids
  end

end
