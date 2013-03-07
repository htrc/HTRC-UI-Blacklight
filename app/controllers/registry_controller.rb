# -*- encoding : utf-8 -*-

class RegistryController < ApplicationController

  include Blacklight::Configurable

  copy_blacklight_config_from(CatalogController)

  helper CatalogHelper

  def index
      token = session[:token]
      registry = Registry.new
      @worksets = registry.list_worksets(current_user.uid, token)
      session[:worksets] = @worksets
  end

  def manage
      token = session[:token]
      registry = Registry.new
      @worksets = registry.list_worksets(current_user.uid, token)
      session[:worksets] = @worksets
  end

  def load
      logger.debug "load"
      token = session[:token]

      id = Integer(params[:ws]) - 1
      workset = session[:worksets][id]
      workset_name = workset["name"]
      registry = Registry.new
      ids = registry.get_workset_volumes(current_user.uid, token, workset_name)

      session[:folder_document_ids] = ids

      respond_to do |format|
         format.html { redirect_to "/blacklight/folder", :notice =>  I18n.t('blacklight.registry.load.success', :name => workset_name) }
         format.js { render :json => session[:folder_document_ids] }
      end
  end

  def export
      logger.debug "export"

      token = session[:token]
   
      if params[:ws] != nil
          id = Integer(params[:ws]) - 1
          workset = session[:worksets][id]
          name = workset["name"]
          desc = workset["description"]
          avail = workset["availability"]
          tags = workset["tags"]
          ids = session[:folder_document_ids]

          registry = Registry.new
          registry.update_workset(current_user.uid, token, name, desc, avail, tags)
          registry.update_volumes(current_user.uid, token, name, ids)

          respond_to do |format|
             format.html { redirect_to "/blacklight/folder",
                                       :notice =>  I18n.t('blacklight.registry.update.success', :name => name) }
             format.js { render :json => session[:folder_document_ids] }
          end
      else
          name = params[:n]
          desc = params[:d]
          avail = params[:a]
          tags = params[:tags]
          ids = session[:folder_document_ids]

          registry = Registry.new
          registry.create_workset(current_user.uid, token, name, desc, avail, tags, ids)

          respond_to do |format|
            format.html { redirect_to "/blacklight/folder",
                                      :notice =>  I18n.t('blacklight.registry.create.success', :name => name) }
            format.js { render :json => session[:folder_document_ids] }
          end
      end
  end
end
