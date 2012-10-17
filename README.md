# Emerald Siren

The Emerald Siren is an extremely simple Ruby script that logs in and scrapes your Starbucks’ account for how many stars and rewards you have. It also returns the balance and transaction history for your main card. It scrapes the page using Mechanize and grabs the data using regular expressions.

In simple: it's an easily broken read-only API for your Starbucks card.


# Let’s Be Clear

* **This is not approved by Starbucks.**
* If Starbucks makes a change to their site it could break.
* I only have one Starbucks card so who knows what kind of crazy will be unleashed if you use it with more than one card.


# How To Use This

Try it out at [emeraldsiren.com](http://emeraldsiren.com) or clone this repo. You can use Emerald Siren as an API to get a JSON output of your balance, stars, and recent transactions.

The API call is simply `http://emeraldsiren.com/USERNAME/PASSWORD` Just remember to replace username and password with your log in details.

Adding /stars /rewards /balance and /last to the end of the API call simply returns a number, amount, or date.


# Cool uses for this

* Make your own iPhone Passbook card with updating balance (and maybe how many stars you have?)
* Track how often you go to Starbucks
* Save transaction history to a database so you have a complete history of how many iced grande soy chais you have had over the year (Let's not tell your psychologist.)


# About the “developer”

Any questions and requests can be send to my email <siren@jakebilbrey.com>. Feel free to take this and modify it to do whatever you want. Any improvements I would love to see added to this project.