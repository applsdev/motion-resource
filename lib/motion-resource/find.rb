module MotionResource
  class Base
    class << self
      def find(id, params = {}, &block)
        fetch_member(member_url.fill_url_params(params.merge(id: id)), &block)
      end

      def find_all(params = {}, &block)
        fetch_collection(collection_url.fill_url_params(params), &block)
      end
      
      def fetch_member(url, &block)
        get(url) do |response, json|
          if response.ok?
            obj = instantiate(json)
            request_block_call(block, obj, response)
          else
            request_block_call(block, nil, response)
          end
        end
      end

      def fetch_collection(url, &block)
        get(url) do |response, json|
          if response.ok?
            objs = []
            arr_rep = nil
            if json.class == Array
              arr_rep = json
            elsif json.class == Hash
              plural = self.name.underscore.pluralize
              if json.has_key?(plural) || json.has_key?(plural.to_sym)
                arr_rep = json[plural] || json[plural.to_sym]
              end
            else
              # the returned data was something else
              # ie a string, number
              request_block_call(block, nil, response)
              return
            end
            arr_rep.each { |one_obj_hash|
              objs << instantiate(one_obj_hash)
            }
            request_block_call(block, objs, response)
          else
            request_block_call(block, nil, response)
          end
        end
      end
      
      def request_block_call(block, default_arg, extra_arg)
        if block
          if block.arity == 1
            block.call default_arg
          elsif block.arity == 2
            block.call default_arg, extra_arg
          else
            raise "Not enough arguments to block"
          end
        else
          raise "No block given"
        end
      end
    end
  end
end