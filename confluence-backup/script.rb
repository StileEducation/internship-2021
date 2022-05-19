puts "how does the api work :("

require 'dotenv'
require 'httparty'
require 'base64'
require 'json'

Dotenv.load

auth_raw = ENV['EMAIL'] + ':' + ENV["API_KEY"] # has to be EMAIL and not USER, otherwise dotenv automatically trims it at the @, breaking the authentication
# puts "raw: " + auth_raw
# puts "encoded: " + Base64.urlsafe_encode64(auth_raw)

headers = { 
  "Content-Type" => "application/json",
  "Authorization" => "Basic " + Base64.urlsafe_encode64(auth_raw) # we need to create an encoded string to put here
}

result = HTTParty.get(
   "https://stileeducation.atlassian.net/wiki/rest/api/space", 
   :headers => headers
)

# pp result

# file = File.open("result.json", "w")

# file.write(result)

# file.close

# puts result["results"][1]["id"]

for space in result["results"] do
  puts space["name"] + " : " + space["key"].to_s
end

space =
  HTTParty.get(
    'https://stileeducation.atlassian.net/wiki/rest/api/space/STILE/content?expand=children.page', # currently hardcoding the space for development
    :headers => headers
  )

pp space

file = File.open("result.json", "w")

file.write(space)

file.close