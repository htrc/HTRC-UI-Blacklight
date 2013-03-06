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

    # Get the current page and per_page parameters
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
   
       # HTRC call, retreiving only the subset of documents to be displayed
       @response, @documents = get_solr_response_for_field_values("id", ids_subset || [])
   
       # Override the :numFound and :start values to support paging
       @response.response[:numFound] = session[:folder_document_ids].length
       @response.response[:start] = (current_page -1) * per_page
       @response.params[:start] = (current_page - 1) * per_page
       
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
 
  # remove a document_id from the folder. :id of action is solr_doc_id
  def destroy
    if (params[:id] == "clear") 
       clear
    else
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
  end
 
  # get rid of the items in the folder
  def clear
    flash[:notice] = I18n.t('blacklight.folder.clear.success')
    session[:folder_document_ids] = []

    # cwillis: delete any stored "select all" flags
    for key in session
      if key[0].starts_with?("selectall")
         session.delete(key[0])
      end
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :json => session[:folder_document_ids] }
    end
  end
 
end
