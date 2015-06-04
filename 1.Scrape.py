# This program downloads player statitics from the ESPNscrum website
# Author: Hautahi Kingi
# Date: 3 June 2015

#-------------------------------------------------------------#
# 1.  Setup
#-------------------------------------------------------------#

print "Code is Working..."

from bs4 import BeautifulSoup
from urllib2 import urlopen
from time import sleep # be nice
import re
import os
import time

#-------------------------------------------------------------#
# 2. Define Strings
#-------------------------------------------------------------#

storage =  "./data/"
BASE_URL = "http://www.espnscrum.com"

#COUNTRY = ["England", "Scotland", "Ireland", "Wales", "SouthAfrica","Australia", "NewZealand", "France", "Argentina", "Italy","Samoa","Tonga","Fiji","Japan","Canada","USA"]

#TEAM_URL = ["/england/rugby/player/caps.html?team=1", "/scotland/rugby/player/caps.html?team=2",    "/ireland/rugby/player/caps.html?team=3",
 #           "/wales/rugby/player/caps.html?team=4",   "/southafrica/rugby/player/caps.html?team=5", "/australia/rugby/player/caps.html?team=6",
  #          "/newzealand/rugby/player/caps.html?team=8", "/france/rugby/player/caps.html?team=9",  "/argentina/rugby/player/caps.html?team=10",
   #         "/italy/rugby/player/caps.html?team=20","/other/rugby/player/caps.html?team=15", "/other/rugby/player/caps.html?team=16",
    #        "/other/rugby/player/caps.html?team=14","/other/rugby/player/caps.html?team=23", "/other/rugby/player/caps.html?team=25","/other/rugby/player/caps.html?team=11"]

COUNTRY = ["Japan","Canada","USA"]

TEAM_URL = ["/other/rugby/player/caps.html?team=23", "/other/rugby/player/caps.html?team=25","/other/rugby/player/caps.html?team=11"]

#-------------------------------------------------------------#
# 3. Define Functions
#-------------------------------------------------------------#

# Note to self: Tidy up the "next's" by using nextSibling
def make_soup(url):
    html = urlopen(url).read()
    return BeautifulSoup(html, "lxml")

def get_player_links(team_url):
    soup = make_soup(team_url)
    Odie = [link.get('href') for link in soup.find_all('a',href=re.compile('/rugby/player'))]
    player_links = [BASE_URL + item for item in Odie]
    for item in player_links:
        if 'team' in item:
            player_links.remove(item)
        elif 'index' in item:
            player_links.remove(item)
    del player_links[0]
    return player_links

def get_player_name(soup):
    name = soup.find('div','scrumPlayerName')
    name = name.next
    return name

def get_player_birth(soup):
    born = soup.find(text=re.compile('Born'))
    born = born.next
    return born

def get_player_tests(soup):
    stats  = soup.find(text=re.compile('All Tests'))
    tests  = stats.next.next.next.next.next.next
    return tests

def get_player_points(soup):
    stats  = soup.find(text=re.compile('All Tests'))
    points = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    return points

def get_player_tries(soup):
    stats  = soup.find(text=re.compile('All Tests'))
    tries = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    return tries

def get_player_wins(soup):
    stats  = soup.find(text=re.compile('All Tests'))
    wins = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    return wins

def get_player_losses(soup):
    stats  = soup.find(text=re.compile('All Tests'))
    losses = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    return losses

def get_player_position(soup):
    stats  = soup.findAll(text=re.compile('Position'))
    stats  = stats[-1]
    position = stats.next  
    return position

def get_player_debut(soup):
    temp  = soup.find(text=re.compile('Test debut'))
    if temp is None:
		stats = soup.find(text=re.compile('Only Test'))
    else:
		stats = temp
    debut = stats.next.next.next
    return debut

#-------------------------------------------------------------#
# 4. Retrieve Data
#-------------------------------------------------------------#

# Loop over each country
for i in range(len(COUNTRY)):
		start_time = time.time() 				# Start timer for this country iteration

		country = COUNTRY[i]
		team_url = BASE_URL + TEAM_URL[i]

		print country

# Retrieve url links for each player from the country page
		links = get_player_links(team_url)
		links_short = links			 			# use this for debugging
		print links[-20]  			  			# print an example, also used for debugging

# Retrieve player statistics from each player's page
		NAMES  = []
		BIRTH  = []
		TESTS  = []
		POINTS = []
		TRIES  = []
		WINS   = []
		LOSSES = []
		DEBUT  = []
		POSITION = []

		for link in links_short:
			soup=make_soup(link)
			
			name = get_player_name(soup)
			NAMES.append(name)

			born = get_player_birth(soup)
			BIRTH.append(born)
			BIRTH = map(lambda s: s.strip(), BIRTH)

			test = get_player_tests(soup)
			TESTS.append(test)
			TESTS = map(lambda s: s.strip(), TESTS)

			points = get_player_points(soup)
			POINTS.append(points)
			POINTS = map(lambda s: s.strip(), POINTS)

			tries = get_player_tries(soup)
			TRIES.append(tries)
			TRIES = map(lambda s: s.strip(), TRIES)

			wins = get_player_wins(soup)
			WINS.append(wins)
			WINS = map(lambda s: s.strip(), WINS)

			losses = get_player_losses(soup)
			LOSSES.append(losses)
			LOSSES = map(lambda s: s.strip(), LOSSES)
			
			debut = get_player_debut(soup)
			DEBUT.append(debut)
			DEBUT = map(lambda s: s.strip(), DEBUT) 
			
			position = get_player_position(soup)
			POSITION.append(position)
			POSITION = map(lambda s: s.strip(), POSITION)
			
# Create country directory if it does not exist
		if not os.path.isdir(storage + country):
			os.makedirs(storage + country)

# Save data as text files (making sure to break down into utf8 bytes)
		f = open(storage + country + "/player_links.txt", "w+")
		f.write("\n".join(x.encode('utf8') for x in links))
		f.close()

		f = open(storage + country + "/names.txt", "w+")
		f.write("\n".join(x.encode('utf8') for x in NAMES))
		f.close()

		f = open(storage + country + "/birth.txt", "w+")
		f.write("\n".join(x.encode('utf8') for x in BIRTH))
		f.close()

		f = open(storage + country + "/tests.txt", "w+")
		f.write("\n".join(x.encode('utf8') for x in TESTS))
		f.close()

		f = open(storage + country + "/points.txt", "w+")
		f.write("\n".join(x.encode('utf8') for x in POINTS))
		f.close()

		f = open(storage + country + "/tries.txt", "w+")
		f.write("\n".join(x.encode('utf8') for x in TRIES))
		f.close()

		f = open(storage + country + "/wins.txt", "w+")
		f.write("\n".join(x.encode('utf8') for x in WINS))
		f.close()

		f = open(storage + country + "/losses.txt", "w+")
		f.write("\n".join(x.encode('utf8') for x in LOSSES))
		f.close() 

		f = open(storage + country + "/positions.txt", "w+")
		f.write("\n".join(x.encode('utf8') for x in POSITION))
		f.close()
		f = open(storage + country + "/debut.txt", "w+")
		f.write("\n".join(x.encode('utf8') for x in DEBUT))
		f.close()

		print("--- %s seconds ---" % (time.time() - start_time))	# print execution time
