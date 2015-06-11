# -*- encoding : utf-8 -*-

class RegistryController < ApplicationController

  include Blacklight::Configurable

  copy_blacklight_config_from(CatalogController)

  helper CatalogHelper

  def index
      token = session[:token]
      registry = Registry.new

      if (!token.nil? && !current_user.nil?)
        @worksets = registry.list_worksets(current_user.uid, token, false)
        session[:worksets] = @worksets

        @myworksets = []
        @worksets.each do |workset|
          if (workset['author'] == current_user.uid)
            @myworksets << workset
          end
        end
        session[:myworksets] = @myworksets
      end
  end

  def manage
    token = session[:token]
    registry = Registry.new
    if (!token.nil? && !current_user.nil?)
      begin
        @worksets = registry.list_worksets(current_user.uid, token, true)
        session[:worksets] = @worksets

        @myworksets = []
        @worksets.each do |workset|
          if (workset['author'] == current_user.uid)
            @myworksets << workset
          end
        end
        session[:myworksets] = @myworksets
      rescue Exceptions::SessionExpiredError => e
          flash[:notice] = I18n.t('blacklight.session.expired');
          sign_out_and_redirect(current_user)
      rescue  Exceptions::SystemError => e
        flash[:notice] = e;
      end
    end
  end

  def load
      logger.debug "load"
      token = session[:token]


      if (!token.nil? && !current_user.nil?)
        begin
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
        rescue Exceptions::SessionExpiredError => e
          flash[:notice] = I18n.t('blacklight.session.expired');
          redirect_to destroy_user_session_path;
        rescue  Exceptions::SystemError => e
          flash[:notice] = e;
        end
      end
  end

  def export
      logger.debug "export"

      token = session[:token]

      if (!token.nil? && !current_user.nil?)
        begin
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
        rescue Exceptions::SessionExpiredError => e
          flash[:notice] = I18n.t('blacklight.session.expired');
          redirect_to destroy_user_session_path;
        rescue  Exceptions::SystemError => e
          flash[:notice] = e;
        end
      end
  end

  def remove
    logger.debug "remove"
    token = session[:token]


    if (!token.nil? && !current_user.nil?)
      begin
        id = Integer(params[:ws]) - 1
        workset = session[:worksets][id]
        workset_name = workset["name"]
        registry = Registry.new
        registry.delete_workset(token, workset_name)

        # flash[:notice] = I18n.t('blacklight.registry.remove.success', :name => workset_name)

        respond_to do |format|
          format.html { redirect_to registry_manage_path, :notice =>  I18n.t('blacklight.registry.remove.success', :name => workset_name) }
          format.js { render :json => session[:folder_document_ids] }
        end

      rescue Exceptions::SessionExpiredError => e
        flash[:notice] = I18n.t('blacklight.session.expired');
        redirect_to destroy_user_session_path;
      rescue  Exceptions::SystemError => e
        flash[:notice] = e;
      end
    end
  end
end
