# -*- encoding : utf-8 -*-
class FolderController < ApplicationController
  include LocalSolrHelperExtension
  include Blacklight::Configurable
  include Blacklight::SolrHelper

  copy_blacklight_config_from(CatalogController)

  helper CatalogHelper

  # fetch the documents that match the ids in the folder
  def index

    #
    # cwillis (8/16/2012) - Added this hack to get around limitation
    # on the number of ids that can be passed in a solr query. The 
    # original FolderController queries all ids stored in the selected
    # items list. Instead, get only the ids for the current page.
    #

    # NOTE: Ids are not necessarily ordered in any particular way
    #   Get the current page and per_page parameters
    if (params[:page].nil?)
      current_page = 1
    else
      current_page = Integer(params[:page])
    end
    per_page = Integer(params[:per_page] || 10)
    start_pos = (current_page - 1) * per_page

    # Get the subset of ids for the current page
    if (session[:folder_document_ids])
      ids_subset = session[:folder_document_ids].slice(start_pos, per_page);

      # Temporarily override the :page parameter (used by get_solr_response_for_field_values)
      params[:page] = 1

      # Original call from Blacklight, gets all documents
      #@response, @documents = get_solr_response_for_field_values("id", session[:folder_document_ids] || [])
   
      # HTRC call, retrieving only the subset of documents to be displayed
       @response, @documents = get_solr_response_for_field_values("id", ids_subset || [])
   
       # Override the :numFound and :start values to support paging
       @response.response[:numFound] = session[:folder_document_ids].length
       @response.response[:start] = (current_page -1) * per_page
       @response.params[:start] = (current_page - 1) * per_page
       @response.response[:rows] = per_page
       @response.params[:rows] = per_page
       
    else 
       @response = Array.new
       @documents = Array.new
    end

    # Reset the :page parameter
    params[:page] = current_page || 1
  end
    

  # add a document_id to the folder. :id of action is solr doc id
  def update
    session[:folder_document_ids] = session[:folder_document_ids] || []
    session[:folder_document_ids] << params[:id] 

    # Rails 3 uses a one line notation for setting the flash notice.
    #    flash[:notice] = "#{params[:title] || "Item"} successfully added to Folder"
    respond_to do |format|
      format.html { redirect_to :back, :notice =>  I18n.t('blacklight.folder.add.success', :title => params[:title] || 'Item') }
      format.js { render :json => session[:folder_document_ids] }
    end
  end

  # add document_ids on page to the folder.
  def update_page

    # Initialize stored document ids, if empty
    if (session[:folder_document_ids].nil?)
      session[:folder_document_ids] = Array.new
    end

    # Get the current list of stored document ids
    selected = session[:folder_document_ids]

    # Get the list of ids for the current page
    ids = get_page_ids_for_query()

    # Add any missing ids to the list of selected document ids
    #   two ways to do this...
    #  session[:folder_document_ids] = (selected + ids).uniq
    session[:folder_document_ids] = (selected.concat(ids)).uniq

    flash[:notice] = I18n.t('blacklight.folder.page.add.success')
    # JSON response for JQuery checkbox includes the total number ids
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => { :count => session[:folder_document_ids].length } }
    end
  end

  # add All document_ids in query to the folder.
  def update_all_search

    # Initialize stored document ids, if empty
    if (session[:folder_document_ids].nil?)
      session[:folder_document_ids] = Array.new
    end

    # Get the current list of stored document ids
    selected = session[:folder_document_ids]

    # Get the list of ids for the current query
    ids = get_all_ids_for_query()

    # Add any missing ids to the list of selected document ids
    #   two ways to do this...
    #  session[:folder_document_ids] = (selected + ids).uniq
    session[:folder_document_ids] = (selected.concat(ids)).uniq

    flash[:notice] = I18n.t('blacklight.folder.search.add.success')
    # JSON response for JQuery checkbox includes the total number ids
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => { :count => session[:folder_document_ids].length } }
    end

  end

  # remove a document_id from the folder. :id of action is solr_doc_id
  def destroy
    session[:folder_document_ids].delete(params[:id])

    respond_to do |format|
      format.html do
        flash[:notice] = I18n.t('blacklight.folder.remove.success', :title => params[:title] || 'Item')
        redirect_to :back
      end
      format.js do
        render :json => {"OK" => "OK"}
      end
    end
  end

  # get rid of ALL the items in the folder
  def clear
    session[:folder_document_ids] = []

    # cwillis: delete any stored "select all" flags
    # for key in session
    #   if key[0].starts_with?("selectall")
    #     session.delete(key[0])
    #   end
    # end

    flash[:notice] = I18n.t('blacklight.folder.all.remove.success')

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :json => session[:folder_document_ids] }
    end
  end

  # get rid of the all the present search items in the folder
  def clear_all_search

    # Get the current list of stored document ids
    selected = session[:folder_document_ids]

    # Get the list of ids for the current query
    ids = get_all_ids_for_query()

    #  Remove any ids in current search that are already on list selected document ids (Assume ids are unique)
    session[:folder_document_ids] = session[:folder_document_ids] - ids
    # longer way to do above statement:
    # for id in ids
    #    session[:folder_document_ids].delete[id]
    #  end

    flash[:notice] = I18n.t('blacklight.folder.search.remove.success')

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :json => session[:folder_document_ids] }
    end
  end

  # get rid of the page-items in the folder
  def clear_page
    # Get the current list of stored document ids
    selected = session[:folder_document_ids]

    # Get the list of ids for the current query
    ids = get_page_ids_for_query()

    #  Remove any ids in current search that are already on list selected document ids (Assume ids are unique)
    session[:folder_document_ids] = session[:folder_document_ids] - ids
    # longer way to do above atatement:
    # for id in ids
    #    session[:folder_document_ids].delete[id]
    #  end

    flash[:notice] = I18n.t('blacklight.folder.page.remove.success')

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :json => session[:folder_document_ids] }
    end
  end

  private

  # Run the current query to retrieve current page ids
  def get_page_ids_for_query

    # We already have the current query and associated :rows & :start parameters
      #   so NOT needed: Get the current page and per_page parameters
      # if (session[:search][:page].nil?)
      #  current_page = 1
      # else
      #   current_page = Integer(session[:search][:page])
      # end
      # per_page = Integer(session[:search][:start] || 10)
      # start_pos = (current_page - 1) * per_page

    ids = Array.new

    # Construct Solr query
    solr_params = Hash.new
    solr_params[:fl] = "id"
    # solr_params[:rows] = per_page
    # solr_params[:start] = start_pos

    @response, @documents = get_search_results(session[:search], solr_params)

    # Populate the list of ids
    for doc in @response.response[:docs]
      ids << doc[:id]
    end

    return ids
  end

  # Run the current query to retrieve all ids
  def get_all_ids_for_query

    ids = Array.new

    # Total number of documents from current query
    total_docs = session[:search][:total]

    # Construct Solr query
    solr_params = Hash.new
    solr_params[:fl] = "id"
    solr_params[:rows] = total_docs
    # solr_params[:rows] = 1000 # Limit to 1000 for now
    solr_params[:start] = "0"

    @response, @documents = get_search_results(session[:search], solr_params)

    # start = @response.response[:start]
    num_found = @response.response[:numFound]

    # sanity check here
    if (num_found != total_docs)
      # TODO... return some error here
    end

    # Populate the list of ids
    for doc in @response.response[:docs]
      ids << doc[:id]
    end

    return ids
  end

end
