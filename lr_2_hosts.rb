#!/usr/bin/ruby
require "socket"
require "resolv"
require "ipaddr"
require "packetfu" #gem install packetfu| sudo apt-get install libpcap-dev | gem install pcaprub

def computer_exists?(fwip)
  system("ping -c1 -w1 #{fwip}")
end

def send_arm ip
  PacketFu::Utils::arp(ip, :iface => "wlan0") 
end

def append_to_file(line)
  file = File.open("results.csv", "a")
  file.puts(line)
  file.close
end

def getInfo(current_ip)
  begin
    if computer_exists?(current_ip)
      host_name = Socket.getaddrinfo(current_ip,nil)
      arp_answ = send_arm(current_ip).inspect
      append_to_file("#{current_ip},UP,#{host_name[0][2]}, #{arp_answ}\n")
    else
      append_to_file("#{current_ip},DOWN,NoNAME\n")
    end
    rescue SocketError => mySocketError
    append_to_file("#{current_ip},UP,ERROR")
  end
end

ipLST="IP.txt"
puts "My mac is #{PacketFu::Utils.whoami?(:iface => 'wlan0')[:eth_saddr]}"
method = File.readlines(ipLST).first
puts "Method is #{method}"
if method.chomp == "list"
  File.readlines(ipLST).each_with_index do |line, index|
    if index != 0
      current_ip = "#{line}"
      getInfo(current_ip)
    end
  end
else
  first_ip = IPAddr.new(File.readlines(ipLST)[1].chomp)
  last_ip = IPAddr.new(File.readlines(ipLST)[2].chomp)
  range = (first_ip...last_ip)
  puts "First ip: #{first_ip} and last ip: #{last_ip}"
  puts range
  range.each do |line|
    current_ip = "#{line}"
    getInfo(line.to_s)
  end
end  