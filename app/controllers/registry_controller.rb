# -*- encoding : utf-8 -*-

#
# Controller for exporting a collection to the registry
#
#
# <collection>
#  <collection_properties>
#    <e key="name">An elaborate and clever collection name</e>
#    <e key="description">Some descriptive text</e>
#    <e key="availability">public</e>
#    <e key="tags">argle,bargle,nonsense</e>
#  </collection_properties>
#  <ids>
#    <id>book1</id>
#    <id>book2</id>
#    <id>book3</id>
#    <id>book4</id>
#  </ids>
# </collection>

class RegistryController < ApplicationController

  include Blacklight::Configurable

  copy_blacklight_config_from(CatalogController)

  helper CatalogHelper

  def index
      #token = login
      token = session[:token]
      @collections = list_collections(token)
      session[:collections] = @collections
  end

  def manage
      #token = login
      token = session[:token]
      @collections = list_collections(token)
      session[:collections] = @collections
  end

  def load
      logger.debug "load"
      #token = login
      token = session[:token]

      id = Integer(params[:col]) - 1
      collection = session[:collections][id] 
      name = collection["name"]
      ids = get_collection(token, name)

      session[:folder_document_ids] = ids

      respond_to do |format|
         format.html { redirect_to "/blacklight/folder", :notice =>  I18n.t('blacklight.registry.load.success', :name => name) }
         format.js { render :json => session[:folder_document_ids] }
      end
  end

  def export
      logger.debug "export"

      #token = login
      token = session[:token]
   
      if params[:col] != nil
          id = Integer(params[:col]) - 1
          collection = session[:collections][id] 
          name = collection["name"]
          desc = collection["description"]
          avail = collection["availability"]
          tags = collection["tags"]
          modify_collection(token, name, desc, avail, tags)    

          respond_to do |format|
             format.html { redirect_to "/blacklight/folder", :notice =>  I18n.t('blacklight.registry.update.success', :name => name) }
             format.js { render :json => session[:folder_document_ids] }
          end
      else
          name = params[:n]
          desc = params[:d]
          avail = params[:a]
          tags = params[:tags]
          create_collection(token, name, desc, avail, tags)    

          respond_to do |format|
             format.html { redirect_to "/blacklight/folder", :notice =>  I18n.t('blacklight.registry.create.success', :name => name) }
             format.js { render :json => session[:folder_document_ids] }
          end

      end
  end

  #def login 
  ##    url = URI.parse('http://chinkapin.pti.indiana.edu:9000/agent/login')
#
#      http = Net::HTTP.new(url.host, url.port)
#      http.set_debug_output($stdout)
#
#      request = Net::HTTP::Put.new(url.path)
#      request.body = "<?xml version='1.0' encoding='UTF-8'?>" + 
#                     "<credentials>" + 
#                     "<username>willis8</username>" + 
#                     "<password>l0ngPassw0rd</password>" + 
#                     "</credentials>";
#
#      request["Content-Type"] = "text/xml"
#      response = http.request(request)
#      logger.debug "Response Code: #{response.code}"
#
#      xml = response.body
#      logger.debug "Response Body: #{xml}"
#
#      doc = REXML::Document.new(xml)
#      token = doc.elements["/agent/token"][0]
#      logger.debug "Token: #{token}"
#
#      return token
#  end

  def list_collections (token)
      logger.debug "list_collections #{token}"
      logger.debug "current_user #{current_user}"

      # GET root/agent/collection/list
      # <collections>
      #  <collection_properties>LOTS_OF_XML</collection_properties>
      #  <collection_properties>OTHER_BIG_XML</collection_properties>
      # </collections>
      # <collections>
      #   <collection_properties> 
      #     <e key=\"description\">Some descriptive text</e>
      #     <e key=\"name\">An elaborate and clever collection name</e>
      #     <e key=\"tags\">argle,bargle,nonsense</e>
      #     <e key=\"owner\">drhtrc</e>
      #     <e key=\"availability\">public</e>
      #   </collection_properties>
      # </collections>"

      url = URI.parse('http://chinkapin.pti.indiana.edu:9000/agent/collection/list')

      http = Net::HTTP.new(url.host, url.port)
      http.set_debug_output($stdout)

      request = Net::HTTP::Get.new(url.path)
      request.add_field("Authorization", "Bearer #{token}")
      response = http.request(request)
      logger.debug "Response Code: #{response.code}"

      xml = response.body

      collections = Array.new
      doc = REXML::Document.new(xml)
      id=1
      doc.elements.each("/collections/collection_properties/") do |col|
          hash = Hash.new
          col.elements.each("e") do |element| 
             key = element.attributes["key"]
             value = element.text
             hash[key] = value
             logger.debug "\t#{key}, #{value}"
          end

          if (current_user.email == hash['owner'])
             hash['id'] = id
             id = id+1
             collections << hash
          end
      end
      return collections
  end


  def get_collection (token, name)
     logger.debug "get_collection  #{token}, #{name}"

     # GET root/agent/download/collection
     # <collection>
     #   THE_INNER_PART_OF_A_COLLECTION
     # </collection>

     encoded = URI::encode(name)
     uri = "http://chinkapin.pti.indiana.edu:9000/agent/download/collection/#{encoded}"
     url = URI.parse(uri)

     http = Net::HTTP.new(url.host, url.port)
     http.set_debug_output($stdout)

     request = Net::HTTP::Get.new(url.path)
     request.add_field("Authorization", "Bearer #{token}")
     request["Content-Type"] = "text/xml"

     response = http.request(request)
     logger.debug "Response Code: #{response.code}"

     xml = response.body
     logger.debug "XML: #{xml}"
 
     doc = REXML::Document.new(xml)

     ids = Array.new
     doc.elements.each("/collection/ids/id") do |id|
logger.debug id.text
         ids << id.text
     end
logger.debug "IDS: #{ids.inspect}"
     return ids
  end

  def create_collection (token, name, desc, avail, tags)
     logger.debug "create_collection #{token}, #{name}, #{desc}, #{avail}, #{tags}"

     url = "http://chinkapin.pti.indiana.edu:9000/agent/upload/collection"

     create_modify_collection( url, token, name, desc, avail, tags) 
  end
 
  def modify_collection (token, name, desc, avail, tags)
     logger.debug "modify_collection #{token}, #{name}, #{desc}, #{avail}, #{tags}"

     #get_collection(token, name)

     #encoded = URI::encode(name)
     #url = "http://chinkapin.pti.indiana.edu:9000/agent/modify/collection/#{encoded}"
     url = "http://chinkapin.pti.indiana.edu:9000/agent/modify/collection"
     create_modify_collection(url, token, name, desc, avail, tags)
  
  end

  def create_modify_collection(uri, token, name, desc, avail, tags)

     properties = "  <collection_properties>" + 
                  "    <e key='name'>#{name}</e>" + 
                  "    <e key='description'>#{desc}</e>" + 
                  "    <e key='availability'>#{avail}</e>" + 
                  "    <e key='tags'>#{tags}</e>" + 
                  "  </collection_properties>" + 

     volumes = ""
     for id in session[:folder_document_ids]
         volumes += "<id>#{id}</id>" 
     end

     collection = "<collection>#{properties}<ids>#{volumes}</ids></collection>"

logger.debug "URI: #{uri}"
     url = URI.parse(uri)
     http = Net::HTTP.new(url.host, url.port)
     http.set_debug_output($stdout)

     request = Net::HTTP::Put.new(url.path)
     request.add_field("Authorization", "Bearer #{token}")
     request["Content-Type"] = "text/xml"

     request.body = "<?xml version='1.0' encoding='UTF-8'?>#{collection}"

logger.debug "Request: #{request.body}"

     response = http.request(request)
     logger.debug response.inspect
     logger.debug "Response Code: #{response.code}"

     xml = response.body

     #doc = REXML::Document.new(xml)
     logger.debug xml
  end

end
