require 'rubygems'
require 'sinatra'
require 'builder'
require 'mechanize'
require 'nokogiri'
require 'json_builder'

get "/" do
  '<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Emerald Siren</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <meta name="description" content="The Unsanctioned Starbucks API" />
        <meta name="viewport" content="width=500px" />
        <meta charset="utf-8">
        <meta name="keywords" content="starbucks,api,ruby,sinatra,github,repo" />
        <style type="text/css">
        <!--
            body {
                font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
                max-width: 500px;
                padding: 30px;
                margin: 0 auto;
                color: #3E4147;
            }
            
            h1, h2, h3, h4, h5, h6 { font-family: "Helvetica Neue", Helvetica, Arial, sans-serif; }
            
                h1 a, h2 a, h3 a, h4 a {
                    color: #2A2C31;
                    text-decoration: none;
                }
            
            h1 { margin: 0px 0px 20px 0px }
            
            h2 {
                margin: 0px;
                padding: 0px;
            }
            
            .date {
                margin: 0px;
                padding: 0px;
            }
            
            .post {
                padding: 0px 10px;
                margin-bottom: 50px;
            }
            
                .post p a, .post .notes a, .post ul li a, .post ol li a {
                    color: #2A2C31;
                    text-decoration: underline;
                }
            
                .post .date .perma a {
                    color: #AAAAAA;
                    text-decoration: none;
                    font-weight: 300;
                }
            
                .post .tags a {
                    color: #AAAAAA;
                    text-decoration: none;
                    font-size: .9em;
                }
            
            blockquote {
                padding-left: 10px;
                margin: 0px 0px 0px 10px;
                border-left: 2px solid #CCCCCC;
            }
            
            hr {
                border: 0px none;
                border-bottom: 1px solid #EEEEEE;
            }
            
            .source, .notes {
                font-size: .9em;
            }
            
            .post p.notes {
                margin-top: 30px;
            }
            
            .notes img {
                display: none;
            }
            
            .link { text-decoration: underline }
            
            .footnotes {
                font-size: .9em;   
            }
            
            #searchform {
                text-align: center;
            }
            
            #search {
                width: 180px;
            }
            
            #footer, #pages, #paging {
                color: #AAAAAA;
                text-align: center;
                padding: 0px;
            }
            
                #footer a, #paging a {
                    color: #AAAAAA;
                    text-decoration: none;
                }
            
            #pages a {
                padding-left: 5px;
                padding-right: 5px;
                color: #AAAAAA;
                text-decoration: none;
            }
                    
            @media all and (max-width: 500px) {
                img {
                    max-width: 100%;
                }
            }
            
            
        -->
        </style>
    </head>

    <body>
        <h1><a href="/">Emerald Siren</a></h1>

        <div class="post">
            <h2>The Unsanctioned Starbucks API</h2>
            <p><strong>Github</strong></p>
            <p><code><a href="https://github.com/jakebilbrey/emeraldsiren">https://github.com/jakebilbrey/emeraldsiren</a></code></p>
            <p><strong>API Call</strong></p>
            <p><code>http://emeraldsiren.com/USERNAME/PASSWORD</code></p>
            <p><strong>Example Output</strong></p>
            <p><pre>{<br/>
            &#9;"balance": 33.45,<br/>
            &#9;"rewards": 4,<br/>
            &#9;"stars": 9,<br/>
            &#9;"transactions": [<br/>
            &#9;&#9;{<br/>
            &#9;&#9;&#9;"date": "10/1/2012",<br/>
            &#9;&#9;&#9;"type": "In Store Purchase",<br/>
            &#9;&#9;&#9;"amount": -3.65<br/>
            &#9;&#9;},<br/>
            &#9;&#9;{<br/>
            &#9;&#9;&#9;"date": "10/2/2012",<br/>
            &#9;&#9;&#9;"type": "Automatic Reload",<br/>
            &#9;&#9;&#9;"amount": 25.00<br/>
            &#9;&#9;}<br/>
            &#9;]<br/>
            }</pre></p>
            <p><strong>Single Result API Calls</strong></p>
            <p><code>http://emeraldsiren.com/USERNAME/PASSWORD/stars</code></p>
            <p><code>http://emeraldsiren.com/USERNAME/PASSWORD/rewards</code></p>
            <p><code>http://emeraldsiren.com/USERNAME/PASSWORD/balance</code></p>
            <p><code>http://emeraldsiren.com/USERNAME/PASSWORD/last</code></p>
            <p><code>http://emeraldsiren.com/USERNAME/PASSWORD/glance</code></p>
      </div>
</body>
</html>'
end

get "/:username/:password" do |username,password|
  a = Mechanize.new
  page = a.get("https://www.starbucks.com/account/signin?ReturnUrl=/account/card/history")
  form = page.form_with(:action => '/account/signin') do |login|
    login['Account.UserName'] = username
    login['Account.PassWord'] = password
  end.submit
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
    history[historycount]["amount"] = post.children.to_s.scan(/\(?\d+\.\d+/).to_s.gsub(/[\["\]\\]/,"").gsub(/\(/,"-").to_f
    history[historycount]["type"] = post.children.to_s.strip.scan(/>\s+[A-Za-z ]+/).to_s.gsub(/(>|\\r|\\n|\\t|\["|"\])/,"")
    historycount += 1
  }
  # Grab the balance, break it out of an array
  balance = (page/'span.balance.numbers').to_s.scan(/\d+\S\d+/)
  balance = balance[0].to_f
  page = a.get('https://www.starbucks.com/account/home')
  allstars = (page/'span.stars-until')
  rewards = (page/'span.rewards_cup_gold')
  rewards = rewards[0].to_s.strip.scan(/\d+/)
  rewards = rewards[0].to_i
  stars = allstars[0].to_s.strip.scan(/\d+/)
  stars = stars[0].to_i
  stars = 12-stars

  json = JSONBuilder::Compiler.generate do
    balance balance
    stars stars
    rewards rewards
    transactions history do |trans|
        date trans["date"]
        type trans["type"]
        amount trans["amount"]
    end
  end
end

get "/:username/:password/stars" do |username,password|
  a = Mechanize.new
  page = a.get("https://www.starbucks.com/account/signin?ReturnUrl=/account/home")
  form = page.form_with(:action => '/account/signin') do |login|
    login['Account.UserName'] = username
    login['Account.PassWord'] = password
  end.submit
  page = a.get('https://www.starbucks.com/account/home')
  allstars = (page/'span.stars-until')
  stars = allstars[0].to_s.strip.scan(/\d+/)
  stars = stars[0].to_i
  stars = 12-stars
  "#{stars}"
end

get "/:username/:password/rewards" do |username,password|
  a = Mechanize.new
  page = a.get("https://www.starbucks.com/account/signin?ReturnUrl=/account/home")
  form = page.form_with(:action => '/account/signin') do |login|
    login['Account.UserName'] = username
    login['Account.PassWord'] = password
  end.submit
  page = a.get('https://www.starbucks.com/account/home')
  rewards = (page/'span.rewards_cup_gold')
  rewards = rewards[0].to_s.strip.scan(/\d+/)
  rewards = rewards[0].to_i
  "#{rewards}"
end

get "/:username/:password/balance" do |username,password|
  a = Mechanize.new
  page = a.get("https://www.starbucks.com/account/signin?ReturnUrl=/account/card/history")
  form = page.form_with(:action => '/account/signin') do |login|
    login['Account.UserName'] = username
    login['Account.PassWord'] = password
  end.submit
  page = a.get('https://www.starbucks.com/account/card/history')
  balance = (page/'span.balance.numbers').to_s.scan(/\d+\S\d+/)
  balance = balance[0].to_f
  "#{balance}"
end

get "/:username/:password/last" do |username,password|
  a = Mechanize.new
  page = a.get("https://www.starbucks.com/account/signin?ReturnUrl=/account/card/history")
  form = page.form_with(:action => '/account/signin') do |login|
    login['Account.UserName'] = username
    login['Account.PassWord'] = password
  end.submit
  rawhistory = []
  page = a.get('https://www.starbucks.com/account/card/history')
  rawhistory += (page/'#history tbody tr')
  page = a.get('https://www.starbucks.com/account/card/history/2')
  rawhistory += (page/'#history tbody tr')
  history = []
  historycount = 0
  rawhistory.each { |post|
    history[historycount] = Hash.new
    history[historycount]["date"] = post.children.to_s.scan(/\d+\/\d+\/\d+/).to_s.gsub(/[\["\]\\]/,"")
    history[historycount]["amount"] = post.children.to_s.scan(/\(?\d+\.\d+/).to_s.gsub(/[\["\]\\]/,"").gsub(/\(/,"-").to_f
    history[historycount]["type"] = post.children.to_s.strip.scan(/>\s+[A-Za-z ]+/).to_s.gsub(/(>|\\r|\\n|\\t|\["|"\])/,"")
    historycount += 1
  }
  last = ""
  history.each { |post|
    if post["type"] == "In Store Purchase"
        last = post["date"]
    end
  }
  "#{last}"
end

get "/:username/:password/glance" do |username,password|
  a = Mechanize.new
  page = a.get("https://www.starbucks.com/account/signin?ReturnUrl=/account/card/history")
  form = page.form_with(:action => '/account/signin') do |login|
    login['Account.UserName'] = username
    login['Account.PassWord'] = password
  end.submit
  page = a.get('https://www.starbucks.com/account/card/history')
  balance = (page/'span.balance.numbers').to_s.scan(/\d+\S\d+/)
  balance = balance[0].to_f
  page = a.get('https://www.starbucks.com/account/home')
  allstars = (page/'span.stars-until')
  rewards = (page/'span.rewards_cup_gold')
  rewards = rewards[0].to_s.strip.scan(/\d+/)
  rewards = rewards[0].to_i
  stars = allstars[0].to_s.strip.scan(/\d+/)
  stars = stars[0].to_i
  stars = 12-stars
  "$#{balance}  Rewards: #{rewards}  Stars: #{stars}"
end
