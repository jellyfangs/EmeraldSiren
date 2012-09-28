require 'rubygems'
require 'sinatra'
require 'builder'
require 'mechanize'
require 'nokogiri'

username = "YOUR-USERNAME"
password = "YOUR-PASSWORD"

a = Mechanize.new 

# Log in to Starbucks
page = a.get("https://www.starbucks.com/account/signin?ReturnUrl=/account/card/history")
form = page.form_with(:action => '/account/signin') do |login|
  login['Account.UserName'] = username
  login['Account.PassWord'] = password
end.submit

get "/" do

  # Grab history 
  # Starbucks limits how far back you can go so this just grabs two pages
  rawhistory = []
  page = a.get('https://www.starbucks.com/account/card/history')
  rawhistory += (page/'#history tbody tr')
  page = a.get('https://www.starbucks.com/account/card/history/2')
  rawhistory += (page/'#history tbody tr')
  history = []
  historycount = 0
  rawhistory.each { |post|
    # Remove HTML and put the transation history into a simple array of hashes
    history[historycount] = Hash.new
    history[historycount]["date"] = post.children.to_s.scan(/\d+\/\d+\/\d+/).to_s.gsub(/[\["\]\\]/,"")
    history[historycount]["amount"] = post.children.to_s.scan(/\(?\d+\.\d+\)?\s\w+/).to_s.gsub(/[\["\]\\]/,"")
    history[historycount]["type"] = post.children.to_s.strip.scan(/>\s+[A-Za-z ]+/).to_s.gsub(/(>|\\r|\\n|\\t|\["|"\])/,"")
    historycount += 1
  }

  # Grab the balance
  balance = (page/'span.balance.numbers')

  # Pull the number of stars you current have from their
  # Flash applet
  page = a.get('https://www.starbucks.com/account/rewards')
  rawstars = (page/'script')
  stars = rawstars[24].children.to_s.scan(/flashvars.numStars = "\d+"/)
  stars = stars[0].gsub(/\D/,"")

  # Echo out what we have got!
  html = ""
  html += "Your balance is #{balance} <br/>"
  html += "You have #{stars} stars. <br/><br/>"

  html += "Your transaction history: </br>"
  history.each { |transaction|
    html += "#{transaction["date"]} - #{transaction["type"]} - #{transaction["amount"]}<br/>"
  }

  html

end

