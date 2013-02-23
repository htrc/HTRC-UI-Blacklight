class Registry

  # Create or update a workset
  def create_workset (username, workset_name, description, availability, tags, volume_ids)
    Rails.logger.debug("create_workset #{username}, #{workset_name}, #{description}, #{availability}, #{tags}")

    workset_xml =
        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
        " <workset xmlns=\"http://registry.htrc.i3.illinois.edu/entities/workset\">" +
        "  <metadata>" +
        "    <name>#{workset_name}</name>" +
        "    <description>#{description}</description>" +
        "    <author>#{username}</author>" +
        #"    <availability>#{availability}</availability>" +
        "    <tags><tag>#{tags}</tag></tags>" +
        "  </metadata>"+
        "  <content>";

    volumes_xml = "    <volumes>"
    for id in volume_ids
      volumes_xml += "<volume><id>#{id}</id></volume>"
    end
    volumes_xml += "</volumes>"

    workset_xml += volumes_xml + " </workset>"

    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets?user=#{username}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url.request_uri)
    request["Content-Type"] = "application/vnd.htrc-workset+xml"
    request.body = workset_xml

    response = http.request(request)

    response_xml = response.body
    Rails.logger.debug(response_xml)

  end

  def update_workset (username, workset_name, description, availability, tags)
    Rails.logger.debug("update_workset #{username}, #{workset_name}, #{description}, #{availability}, #{tags}")

    workset_xml =
        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
            " <workset xmlns=\"http://registry.htrc.i3.illinois.edu/entities/workset\">" +
            "  <metadata>" +
            "    <name>#{workset_name}</name>" +
            "    <description>#{description}</description>" +
            "    <author>#{username}</author>" +
            #"    <availability>#{availability}</availability>" +
            "    <tags><tag>#{tags}</tag></tags>" +
            "  </metadata>"+
            " </workset>"

    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets/#{workset_name}?user=#{username}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Put.new(url.request_uri)
    request["Content-Type"] = "application/vnd.htrc-workset+xml"
    request.body = workset_xml

    response = http.request(request)

    response_xml = response.body
    Rails.logger.debug(response_xml)

  end

  # Update volumes associated with the workset
  def update_volumes(username, workset_name, volume_ids)

    #<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    #<volumes xmlns="http://registry.htrc.i3.illinois.edu/entities/workset">
    #  <volume>
    #   <id>9999999</id>
    #  </volume>
    #  <volume>
    #   <id>3333333</id>
    #  </volume>
    # </volumes>
    volumes_xml =
        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
        "<volumes xmlns=\"http://registry.htrc.i3.illinois.edu/entities/workset\">";

    for id in volume_ids
      volumes_xml += "<volume><id>#{id}</id></volume>"
    end
    volumes_xml += "</volumes>"


    # curl -v --data @new_volumes.xml -X PUT \
    #   -H "Content-Type: application/vnd.htrc-volume+xml" \
    #   -H "Accept: application/vnd.htrc-volume+xml" \
    #   http://localhost:9763/ExtensionAPI-0.1.0/services/worksets/workset1/volumes?user=fred

    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets/#{workset_name}/volumes?user=#{username}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Put.new(url.request_uri)
    request["Content-Type"] = "application/vnd.htrc-volume+xml"

    request.body = volumes_xml
    response = http.request(request)

    xml = response.body

  end

  # Create or update volumes associated with the workset
  def create_update_volumes(username, workset_name, volume_ids)

    #<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    #<volumes xmlns="http://registry.htrc.i3.illinois.edu/entities/workset">
    #  <volume>
    #   <id>9999999</id>
    #  </volume>
    #  <volume>
    #   <id>3333333</id>
    #  </volume>
    # </volumes>
    volumes_xml =
        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
            "<volumes xmlns=\"http://registry.htrc.i3.illinois.edu/entities/workset\">";

    for id in volume_ids
      volumes_xml += "<volume><id>#{id}</id></volume>"
    end
    volumes_xml += "</volumes>"


    # curl -v --data @new_volumes.xml -X PUT \
    #   -H "Content-Type: application/vnd.htrc-volume+xml" \
    #   -H "Accept: application/vnd.htrc-volume+xml" \
    #   http://localhost:9763/ExtensionAPI-0.1.0/services/worksets/workset1/volumes?user=fred

    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets/#{workset_name}?user=#{username}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Put.new(url.path)
    request["Content-Type"] = "application/vnd.htrc-volume+xml"

    request.body = volumes_xml
    response = http.request(request)

    xml = response.body

  end


  # List  worksets accessible by the specified user
  def list_worksets (username)
    Rails.logger.debug "list_public_worksets #{username}"

    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets?user=#{username}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url.request_uri)
    request.add_field("Accept", "application/vnd.htrc-workset+xml")
    response = http.request(request)
    Rails.logger.debug "Response Code: #{response.code}"

    response_xml = response.body
    Rails.logger.debug response_xml

    worksets = Array.new

    doc = REXML::Document.new(response_xml)
    id=1
    doc.elements.each("/worksets/workset/metadata") { |metadata|
      hash = Hash.new
      hash['name'] = metadata.elements['name'].text
      hash['description'] = metadata.elements['description'].text
      hash['author'] = metadata.elements['author'].text

      if (hash['availability'] == "public" || username == hash['author'])
        hash['id'] = id
        id = id+1
        worksets << hash
      end
    }
    return worksets
  end


  # Get the attributes of the specified workset
  def get_workset  (username, workset_name)
    Rails.logger.debug "get_workset  #{username}, #{workset_name}"

    #curl -v -X GET -H "Accept: application/vnd.htrc-workset+xml" \
    # http://localhost:9763/ExtensionAPI-0.1.0/services/worksets/workset1?user=fred

    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets/#{workset_name}?user=#{username}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url.request_uri)
    request.add_field("Accept", "application/vnd.htrc-workset+xml")
    response = http.request(request)
    Rails.logger.debug "Response Code: #{response.code}"

    response_xml = response.body
    Rails.logger.debug response_xml

    doc = REXML::Document.new(response_xml)
    workset = Hash.new
    doc.elements.each("/workset/metadata") { |metadata|

      workset['name'] = metadata.elements['name'].text
      workset['description'] = metadata.elements['description'].text
      workset['author'] = metadata.elements['author'].text

    }
    return workset

  end


  # Get the volume IDs for the specified workset
  def get_workset_volumes  (username, workset_name)
    Rails.logger.debug "get_workset_volumes  #{username}, #{workset_name}"
    url = URI.parse("#{APP_CONFIG['registry_url']}/worksets/#{workset_name}/volumes?user=#{username}")
    http = Net::HTTP.new(url.host, url.port)
    http.set_debug_output($stdout)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url.request_uri)
    request.add_field("Accept", "application/vnd.htrc-workset+xml")
    response = http.request(request)
    Rails.logger.debug "Response Code: #{response.code}"

    volumes = response.body
    ids = volumes.split(" ")
    return ids
  end

end
