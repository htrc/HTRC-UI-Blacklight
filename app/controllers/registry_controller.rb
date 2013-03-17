# -*- encoding : utf-8 -*-

class RegistryController < ApplicationController

  include Blacklight::Configurable

  copy_blacklight_config_from(CatalogController)

  helper CatalogHelper

  def index
      token = session[:token]
      registry = Registry.new
      if (token.nil? || current_user.nil?)
        flash[:notice] = I18n.t('blacklight.session.expired')
      else
        @worksets = registry.list_worksets(current_user.uid, token, false)
        session[:worksets] = @worksets
      end
  end

  def manage
      token = session[:token]
      registry = Registry.new
      if (token.nil? || current_user.nil?)
        flash[:notice] = I18n.t('blacklight.session.expired')
      else
        @worksets = registry.list_worksets(current_user.uid, token, true)
        session[:worksets] = @worksets
      end
  end

  def load
      logger.debug "load"
      token = session[:token]

      if (token.nil? || current_user.nil?)
        flash[:notice] = I18n.t('blacklight.session.expired')
      else
        id = Integer(params[:ws]) - 1
        workset = session[:worksets][id]
        workset_name = workset["name"]
        author = workset["author"]
        registry = Registry.new
        ids = registry.get_workset_volumes(author, token, workset_name)

        session[:folder_document_ids] = ids

        respond_to do |format|
           format.html { redirect_to "/blacklight/folder", :notice =>  I18n.t('blacklight.registry.load.success', :name => workset_name) }
           format.js { render :json => session[:folder_document_ids] }
        end
      end
  end

  def export
      logger.debug "export"

      token = session[:token]
      if (token.nil? || current_user.nil?)
        flash[:notice] = I18n.t('blacklight.session.expired')
      else

        if params[:ws] != nil
            id = Integer(params[:ws]) - 1
            workset = session[:worksets][id]
            name = workset["name"]
            desc = workset["description"]
            avail = params[:a]
            #avail = workset["availability"]
            tags = workset["tags"]
            author = workset["author"]
            ids = session[:folder_document_ids]

            registry = Registry.new
            ret = registry.update_workset(current_user.uid, token, name, desc, avail, tags)
            ret = registry.update_volumes(current_user.uid, token, name, ids)

            flash[:notice] = I18n.t('blacklight.folder.search.remove.success')

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
end
