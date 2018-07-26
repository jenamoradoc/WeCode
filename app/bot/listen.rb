require "facebook/messenger"
include Facebook::Messenger
require 'net/http'
require 'uri'
require 'json'

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

def GetAccessToken
    url = URI("https://graph.facebook.com/v3.0/oauth/access_token? grant_type=fb_exchange_token&client_id=432596000483437&client_secret=270b172b42d4fccd6be9b5e9c8ae63f2&fb_exchange_token=#{ENV["ACCESS_TOKEN"]}&%20grant_type=fb_exchange_token")

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Get.new(url) 
    response = JSON.parse(http.request(request).read_body)
    return response["access_token"]
end

def BuildMessage(msg)
    url = URI("https://graph.facebook.com/v3.0/me/message_creatives?access_token=#{GetAccessToken}")

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = 'application/json'

    request.body = "{    \n  \"messages\": [\n    {\n    \t\"text\":\"#{msg}\"\n    }\n  ]\n}"
    
    response = JSON.parse(http.request(request).read_body)
    return response["message_creative_id"]
end

def sendBroadcast(msg_id)
    require 'uri'
    require 'net/http'

    url = URI("https://graph.facebook.com/v3.0/me/broadcast_messages?access_token=#{GetAccessToken}")

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = 'application/json' 
    request.body = "{    \n  \"message_creative_id\": #{msg_id},\n  \"notification_type\": \"REGULAR\",\n  \"messaging_type\": \"MESSAGE_TAG\",\n  \"tag\": \"NON_PROMOTIONAL_SUBSCRIPTION\"\n}"

    response = http.request(request) 
end


Bot.on :message do |message|
    
    sender = message.sender['id']

    Message.create({
        author: sender,
        body: message.text
    })

    
    filtered_messages = Message.where("author != ?", sender.to_s).map{|msg| "#{msg.author}: #{msg.body}"}
    filtered_reponses = Reponse.where("sender_id != ?", sender.to_s).map{|msg| msg.body}

    puts "FILTERED MESSAGES: " + filtered_messages.inspect
    puts "FILTERED REPONSES: " + filtered_reponses.inspect

    messages_to_send = filtered_messages - filtered_reponses

    

    
    messages_to_send.each do |msg|
        id_msg = BuildMessage(msg)
        sendBroadcast(id_msg)
    end
    
end
 
Bot.on :message_echo do |message_echo|

    sender = message_echo.sender['id'];
    Reponse.create({
        sender_id: sender.to_s,
        body: message_echo.text.to_s
    })
    
    # message_echo.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
    # message_echo.sender      # => { 'id' => '1008372609250235' }
    # message_echo.seq         # => 73
    # message_echo.sent_at     # => 2016-04-22 21:30:36 +0200
    # message_echo.text        # => 'Hello, bot!'
    # message_echo.attachments # => [ { 'type' => 'image', 'payload' => { 'url' => 'https://www.example.com/1.jpg' } } ]
  
    # Log or store in your storage method of choice (skynet, obviously)
end