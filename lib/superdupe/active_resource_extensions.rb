ActiveResource::HttpMock.instance_eval do #:nodoc:
  def delete_mock(http_method, path) #:nodoc:
    responses.reject! {|r| r[0].path == path && r[0].method == http_method}
  end
end

module ActiveResource #:nodoc:
  class Base
    class << self
      
      # Overwrite the configuration of ActiveResource authentication (self.user). Don't need it for mocking.
      def user=(user)
      end
      
      # Overwrite the configuration of ActiveResource authentication (self.password). Don't need it for mocking.
      def password=(password)
      end

      
      def find(*arguments)
        scope = arguments.slice!(0)
        options = arguments.slice!(0) || {}

        case scope
          when :all then find_every(options)
          when :first then find_every(options).first
          when :last then find_every(options).last
          when :one then find_one(options)
          else find_single(scope, options)
        end
      end
      
      private
      def find_every(options)
        external_request = options[:external_request] if options.has_key?(:external_request)
        
        case from = options[:from]
        when Symbol
          instantiate_collection(get(from, options[:params]))
        when String
          path = "#{from}#{query_string(options[:params])}"
          instantiate_collection(connection.get(path, headers, external_request) || [])
        else
          prefix_options, query_options = split_options(options[:params])
          path = collection_path(prefix_options, query_options)
          instantiate_collection( (connection.get(path, headers, external_request) || []), prefix_options )
        end
      end

      def find_one(options)
        external_request = options[:external_request] if options.has_key?(:external_request)
        
        case from = options[:from]
        when Symbol
          instantiate_record(get(from, options[:params]))
        when String
          path = "#{from}#{query_string(options[:params])}"
          instantiate_record(connection.get(path, headers, external_request))
        end
      end

      def find_single(scope, options)
        external_request = options[:external_request] if options.has_key?(:external_request)
                
        prefix_options, query_options = split_options(options[:params])
        path = element_path(scope, prefix_options, query_options)
        instantiate_record(connection.get(path, headers, external_request), prefix_options)
      end
    end
  end
    
  class Connection #:nodoc:
    def get(path, headers = {}, external_request = false) #:nodoc:
      if external_request
        # Without mocking - standard ActiveResource
        response = request(:get, path, build_request_headers(headers, :get))
      else
        mocked_response = Dupe.network.request(:get, path)
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get(path, {}, mocked_response)
        end
        response = request(:get, path, build_request_headers(headers, :get))
        ActiveResource::HttpMock.delete_mock(:get, path)
      end
      format.decode(response.body)
    end

    
    def post(path, body = '', headers = {}, external_request = false) #:nodoc:
      if external_request
        # external request - standard ActiveResource
        response = request(:post, path, body.to_s, build_request_headers(headers, :post))
      else
        resource_hash = Hash.from_xml(body)
        resource_hash = resource_hash[resource_hash.keys.first]
        resource_hash = {} unless resource_hash.kind_of?(Hash)
        begin
          mocked_response, new_path = Dupe.network.request(:post, path, resource_hash)
          error = false
        rescue Dupe::UnprocessableEntity => e
          mocked_response = {:error => e.message.to_s}.to_xml(:root => 'errors')
          error = true
        end
        ActiveResource::HttpMock.respond_to do |mock|
          if error
            mock.post(path, {}, mocked_response, 422, "Content-Type" => 'application/xml')
          else
            mock.post(path, {}, mocked_response, 201, "Location" => new_path)
          end
        end
        response = request(:post, path, body.to_s, build_request_headers(headers, :post))
        ActiveResource::HttpMock.delete_mock(:post, path)
      end
      response
    end
    
    
    def put(path, body = '', headers = {}, external_request = false) #:nodoc:
      if external_request
        response = request(:put, path, body.to_s, build_request_headers(headers, :put))        
      else
        resource_hash = Hash.from_xml(body)
        resource_hash = resource_hash[resource_hash.keys.first]
        resource_hash = {} unless resource_hash.kind_of?(Hash)
        resource_hash.symbolize_keys!
      
        begin
          error = false
          mocked_response, path = Dupe.network.request(:put, path, resource_hash)
        rescue Dupe::UnprocessableEntity => e
          mocked_response = {:error => e.message.to_s}.to_xml(:root => 'errors')
          error = true
        end
        ActiveResource::HttpMock.respond_to do |mock|
          if error
            mock.put(path, {}, mocked_response, 422, "Content-Type" => 'application/xml')
          else
            mock.put(path, {}, mocked_response, 204)
          end
        end
        response = request(:put, path, body.to_s, build_request_headers(headers, :put))
        ActiveResource::HttpMock.delete_mock(:put, path)
      end

      response
    end


    def delete(path, headers = {}, external_request = false)
      # External requests are not allowed!      
      Dupe.network.request(:delete, path)

      ActiveResource::HttpMock.respond_to do |mock|
        mock.delete(path, {}, nil, 200)
      end
      response = request(:delete, path, build_request_headers(headers, :delete))
      
      ActiveResource::HttpMock.delete_mock(:delete, path)
      response
    end
  end
end
