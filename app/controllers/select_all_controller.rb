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

    # Key used to store whether the select all checkbox is checked for the specified query
    key = get_select_all_query_key
    session[key] = true


logger.debug "#{key} #{session[key]}"

    logger.debug "Key = #{key}; Select All = #{session[key]}"

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
    
    # Key used to store whether the select all checkbox is checked for the specified query
    key = get_select_all_query_key

    # Get the list of currently selected ids
    selected = session[:folder_document_ids]

    if session[key] 
    
       # Get the list of ids for the current query
       ids = get_ids_for_query()
 
       # Remove all ids for the current query from the list of selected ids
       for id in ids
          if (!selected.nil? && selected.include?(id))
             #logger.debug "Removing #{id} from selected items"
             session[:folder_document_ids].delete(id)
          end
       end
    end

    session[key] = false
    logger.debug "Key = #{key}; Select All = #{session[key]}"

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
  
  # cwillis 8/17/2012 -- original implementation uses find directly, but 
  # has issues with the filters. To be deleted.
  def get_ids_for_query2

    ids = Array.new

    # Total number of documents from current query
    total_docs = session[:search][:total]

    #query_params = session[:search]
    #for key in query_params.keys
    #    logger.debug "query_params[#{key.inspect}] = #{query_params[key].inspect}"
    #end

    # Construct Solr query
    solr_params = Hash.new
    solr_params[:q] = session[:search][:q]
    solr_params[:search_field] = session[:search][:search_field]
    solr_params[:fl] = "id"
    solr_params[:rows] = total_docs
    #solr_params[:rows] = 1000 # Limit to 1000 for now
    solr_params[:start] = "0"
    solr_params[:fq] ||= []


logger.debug session[:search][:f]
    # deal with facets
    facet_params = session[:search][:f]
    facet_params.each_pair do |facet_field, value_list|
      Array(value_list).each do |value|
        #solr_params[:fq] << facet_value_to_fq_string(facet_field, value)
        solr_params[:fq] << "#{facet_field}:#{value_list}"
      end
    end

    # Get the results from Solr
    solr_response = find(blacklight_config.solr_request_handler, solr_params)
logger.debug solr_params.inspect
    
    start = solr_response[:response][:start]
    num_found = solr_response[:response][:numFound]
    
    # Populate the list of ids
    for doc in solr_response[:response][:docs]
       ids << doc[:id]
    end
 
    return ids
  end
  
  def get_select_all_query_key
     key = "selectall"
     for field in session[:search] do
        param = String(field[0])
        if param == 'q' || param == 'f' || param == 'search_field'
           key += "|#{field[0]} #{field[1]}"
        end
     end
     return key
     #return "selectall|#{session[:search][:q]}|#{session[:search][:search_field]}"
  end
end
