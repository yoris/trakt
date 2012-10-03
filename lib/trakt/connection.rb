module Trakt
  module Connection
    def connection
      @connection ||= Excon.new("http://api.trakt.tv");
    end
    def require_settings(required)
      required.each do |setting|
        raise "Required setting #{setting} is missing." unless Trakt.settings[setting.to_sym]
      end
    end
    def post(path,body)
      # all posts have username/password
      body.update! {
          'username' => Trakt.settings[:username],
          'password' => Trakt.settings[:password],
      }
      result = connection.post(:path => path + Trakt.settings[:apikey], :body => body.to_json)
      parse(result)
    end
    def parse(result)
      parsed =  JSON.parse result.body
      if parsed.kind_of? Hash and parsed['status'] and parsed['status'] == 'failure'
        raise Error.new(parsed['error'])
      end
      return parsed
    end
    def clean_query(query)
      query.gsub(/[()]/,'').
        gsub(' ','+').
        gsub('&','and').
        gsub('!','').
        chomp
    end
    def get(path,query)
      result = connection.get(:path => path + Trakt.settings[:apikey] + '/' + query)
      parse(result)
    end
  end
end
