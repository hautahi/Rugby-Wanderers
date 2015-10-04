# This program scrapes player statitics from the ESPNscrum website
# Statistics are stored as "pickled" Python objects
# Author: Hautahi Kingi
# Date: 19 June 2015

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
import cPickle

#-------------------------------------------------------------#
# 2. Define Strings
#-------------------------------------------------------------#

storage =  "./data/"
BASE_URL = "http://www.espnscrum.com"

COUNTRY = ["England", "Scotland", "Ireland", "Wales", "SouthAfrica","Australia", "NewZealand", "France", "Argentina", "Italy","Samoa","Tonga","Fiji","Japan","Canada","USA"]

TEAM_URL = ["/england/rugby/player/caps.html?team=1", "/scotland/rugby/player/caps.html?team=2",    "/ireland/rugby/player/caps.html?team=3",
           "/wales/rugby/player/caps.html?team=4",   "/southafrica/rugby/player/caps.html?team=5", "/australia/rugby/player/caps.html?team=6",
           "/newzealand/rugby/player/caps.html?team=8", "/france/rugby/player/caps.html?team=9",  "/argentina/rugby/player/caps.html?team=10",
           "/italy/rugby/player/caps.html?team=20","/other/rugby/player/caps.html?team=15", "/other/rugby/player/caps.html?team=16",
           "/other/rugby/player/caps.html?team=14","/other/rugby/player/caps.html?team=23", "/other/rugby/player/caps.html?team=25","/other/rugby/player/caps.html?team=11"]

#-------------------------------------------------------------#
# 3. Define Functions
#-------------------------------------------------------------#

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

# Create Python dictionary mapping stat names to stat numbers. (Used because the order of stats changes in some years)
def get_stats(soup):

    stats  = soup.find(text=re.compile('All Tests'))
    stat1  = stats.next.next.next.next.next.next
    stat2  = stats.next.next.next.next.next.next.next.next.next
    stat3  = stats.next.next.next.next.next.next.next.next.next.next.next.next
    stat4  = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    stat5  = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    stat6  = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    stat7  = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next 
    stat8  = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    stat9  = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    stat10 = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    stat11 = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    stat12 = stats.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next

    category  = soup.find(text=re.compile('Span'))
    cat1 = category.next.next.next
    cat2 = category.next.next.next.next.next.next
    cat3 = category.next.next.next.next.next.next.next.next.next
    cat4 = category.next.next.next.next.next.next.next.next.next.next.next.next
    cat5 = category.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    cat6 = category.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    cat7 = category.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    cat8 = category.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    cat9 = category.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    cat10 = category.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    cat11 = category.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
    cat12 = category.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next.next
	
    return {str(cat1):str(stat1),str(cat2):str(stat2),str(cat3):str(stat3),str(cat4):str(stat4),str(cat5):str(stat5),str(cat6):str(stat6),str(cat7):str(stat7),str(cat8):str(stat8),str(cat9):str(stat9),str(cat10):str(stat10),str(cat11):str(stat11),str(cat12):str(stat12)}

# Allow user to call the above functions using an import command
if __name__ == "__main__":
	pass

#-------------------------------------------------------------#
# 4. Retrieve and Save Data
#-------------------------------------------------------------#

# Loop over each country
for i in range(len(COUNTRY)):
		start_time = time.time() 				# Start timer for this country iteration

		country = COUNTRY[i]
		team_url = BASE_URL + TEAM_URL[i]

		print country

		# Retrieve url links for each player from the country page
		links = get_player_links(team_url)
		links_short = links		 			# use this for debugging
		print links[-10]  			  		# print an example, also used for debugging

		# Retrieve player statistics from each player's page
		NAMES  = []
		BIRTH  = []
		DEBUT  = []
		POSITION = []
		STATS = []

		for link in links_short:
			soup=make_soup(link)
			
			name = get_player_name(soup)
			name = name.encode('utf8')
			NAMES.append(name)

			born = get_player_birth(soup)
			BIRTH.append(born)
			BIRTH = map(lambda s: s.strip(), BIRTH)
			
			debut = get_player_debut(soup)
			DEBUT.append(debut)
			DEBUT = map(lambda s: s.strip(), DEBUT) 
			
			position = get_player_position(soup)
			POSITION.append(position)
			POSITION = map(lambda s: s.strip(), POSITION)

			stats = get_stats(soup)
			STATS.append(stats)
			
		# Create country directory if it does not exist
		if not os.path.isdir(storage + country):
			os.makedirs(storage + country)
			
		# Save data as Python objects
		cPickle.dump(links,open(storage + country + "/Player_links.p","w+"))
		cPickle.dump(NAMES,open(storage + country + "/Names.p","w+"))
		cPickle.dump(BIRTH,open(storage + country + "/Birth.p","w+"))
		cPickle.dump(DEBUT,open(storage + country + "/Debut.p","w+"))
		cPickle.dump(POSITION,open(storage + country + "/Position.p","w+"))
		cPickle.dump(STATS,open(storage + country + "/Stats.p","w+"))

		print("--- %s seconds ---" % (time.time() - start_time))	# print execution time
