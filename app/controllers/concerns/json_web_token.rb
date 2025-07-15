module JsonWebToken
    SECRET_KEY = Rails.application.credentials.jwt_secret


    #encoding payload/userid
    def self.encode(payload, exp = 24.hours.from_now)   #class method not instance
        payload[:exp] = exp.to_i                        #change to unix timestamp  
        JWT.encode(payload, SECRET_KEY)
    end


    #decoding token
    def self.decode(token)
        decoded = JWT.decode(token, SECRET_KEY)[0]  #gets payload from array
        HashWithIndifferentAccess.new(decoded)  #Wraps the payload hash in a special Rails hash that allows both symbol and string access.
        rescue JWT::DecodeError
            nil
        end
    end




