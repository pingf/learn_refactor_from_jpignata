require "bundler"
Bundler.setup

require "json"
require "thread"
require "httpclient"
require "socket"

queue = Queue.new
client = HTTPClient.new
socket = UDPSocket.new

10.times do
  Thread.new do
    while data = queue.pop
      client.post("https://android.googleapis.com/gcm/send", data, {
        "Authorization" => "key=AIzaSyCGylUm201IvRH-fI31jRX2JqL_RQAAKWY",
        "Content-Type" => "application/json"
      })
    end
  end
end

socket.bind("0.0.0.0", 6889)

while data = socket.recvfrom(4096)
  case data[0].split.first
  when "PING"
    socket.send("PONG", 0, data[1][3], data[1][1])
  when "SEND"
    p data
    data[0][5..-1].match(/([a-zA-Z0-9_\-]*) "([^"]*)/)
    p $2
    json = JSON.generate({
      "registration_ids" => [$1],
      "data" => { "message" => $2 }
    })
    queue << json
  end
end
