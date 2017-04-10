# This program scrapes player statitics from the ESPNscrum website

# Author: Hautahi Kingi
# Date: 19 June 2015

#-------------------------------------------------------------#
# 1.  Setup
#-------------------------------------------------------------#

print("Code is Working...")

from bs4 import BeautifulSoup
from urllib2 import urlopen
import re
import os
import time
import cPickle
from geopy.geocoders import Nominatim
import numpy as np
import pandas as pd
geolocator = Nominatim()

#-------------------------------------------------------------#
# 2. Define Strings
#-------------------------------------------------------------#

storage =  "./data/"
BASE_URL = "http://www.espnscrum.com"

COUNTRY = ["England", "Scotland", "Ireland", "Wales", "SouthAfrica","Australia", "NewZealand", "France", "Argentina", "Italy","Samoa","Tonga","Fiji","Japan","Canada","USA"]

#COUNTRY = ["NewZealand"]

TEAM_URL = ["/england/rugby/player/caps.html?team=1", "/scotland/rugby/player/caps.html?team=2", 
            "/ireland/rugby/player/caps.html?team=3","/wales/rugby/player/caps.html?team=4",
            "/southafrica/rugby/player/caps.html?team=5", "/australia/rugby/player/caps.html?team=6",
            "/newzealand/rugby/player/caps.html?team=8", "/france/rugby/player/caps.html?team=9",
            "/argentina/rugby/player/caps.html?team=10","/italy/rugby/player/caps.html?team=20",
            "/other/rugby/player/caps.html?team=15", "/other/rugby/player/caps.html?team=16",
            "/other/rugby/player/caps.html?team=14","/other/rugby/player/caps.html?team=23",
            "/other/rugby/player/caps.html?team=25","/other/rugby/player/caps.html?team=11"]

#TEAM_URL = ["/newzealand/rugby/player/caps.html?team=8"]

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

def stat_extract(STATS,string):    
    MAT=[]
    for i in range(len(STATS)):
        mat=STATS[i].get(string)
        MAT.append(mat)
    return MAT

def get_country(city):
	location = geolocator.geocode(city,exactly_one=False, timeout=10)
	if location is not None:
		z=[]
		for item in location:
			x=item.address
			z.append(x)
	else:
		z=location
	return z

def extract_debutyear(DEBUT):

    # Separate each string using the comma separator
    odie=[]
    for item in DEBUT:
        x = item.split(',')
        odie.append(x)

    # Extract the string after the last comma and strip any spaces
    debut_year = []
    for row in odie:
		x = row[-1]
		x = x.strip()
		debut_year.append(x)

    return debut_year
    
def extract_birthmonth(BIRTH):

    # Separate each string using the comma separator
	odie=[]
	for item in BIRTH:
		x = item.split(',')
		odie.append(x)

   # Extract the string after the last comma and strip any spaces
	birth_month = []
	for row in odie:
		x = row[0]
		x = x.strip()
		birth_month.append(x)

	return birth_month

def extract_birthyear(BIRTH):

    # Separate each string using the comma separator
	odie=[]
	for item in BIRTH:
		x = item.split(',')
		odie.append(x)

   # Extract the string after the last comma and strip any spaces
	birth_year = []
	for row in odie:
		if len(row)>1:
			x=row[1]
		else:
			x=""
		x = x.strip()
		birth_year.append(x)

	return birth_year

def extract_birthplace(BIRTH):

    # Separate each string using the comma separator
	odie=[]
	for item in BIRTH:
		x = item.split(',')
		odie.append(x)

   # Extract the string after the last comma and strip any spaces
	birth_location = []
	for row in odie:
		x = row[-1]
		x = x.strip()
		birth_location.append(x)

	return birth_location
 
def extract_birth_country(mat,i):
    temp = []
    for row in mat:
        if len(row)>i:
            x = row[-i-1]
            x=x.strip()
        else:
            x = "Missing"
        temp.append(x)
    return temp

# Allow user to call the above functions using an import command
if __name__ == "__main__":
	pass

#-------------------------------------------------------------#
# 4. Retrieve Player Links from Internet
#-------------------------------------------------------------#
"""
print "Retrieving Player Links....."
start_time = time.time()

for i in range(len(COUNTRY)):
    country = COUNTRY[i]
    team_url = BASE_URL + TEAM_URL[i]
    
    print(country)
    
    # Retrieve url links for each player from the country page
    links = get_player_links(team_url)
    
    # Create country directory if it does not exist
    if not os.path.isdir(storage + country):
        os.makedirs(storage + country)
        print("Creating country directory")

    # Save links as Python objects
    cPickle.dump(links,open(storage + country + "/Player_links.p","w+"))

print('Retrieving Player Links took %d seconds' % (time.time() - start_time))
"""

#-------------------------------------------------------------#
# 4. Take most recent of these links
# Put links altogether in one dataframe with country
#-------------------------------------------------------------#

df = pd.DataFrame()
COUNTRY_ARRAY=pd.DataFrame()

# Loop over each country
for country in COUNTRY:

     # Load newly gained links
     LINKnew = cPickle.load(open(storage + country + "/Player_links.p","r"))
     
     # Extract most recent
     LINKnew = LINKnew[-150:len(LINKnew)]
     
     # Throw into dataframe
     COUNTRY_ARRAY = COUNTRY_ARRAY.append(pd.DataFrame(np.repeat(country,len(LINKnew))))
     df = df.append(pd.DataFrame(LINKnew))
     
df['team'] = np.array(COUNTRY_ARRAY[0])

#-------------------------------------------------------------#
# 4. Get info for latest links
#-------------------------------------------------------------#

print "Retrieving Statistics....."

start_time = time.time() 				# Start timer for this country iteration

# Retrieve player statistics from each player's page
NAMES = []
BIRTH = []
DEBUT = []
POSITION = []
STATS = []
CITY = []
BIRTH_COUNTRY = []

for link in df[0]:
    
    # Get page link    
    # soup=make_soup(link)
    
    while True:
        try:
            time.sleep(1)
            soup=make_soup(link)
        except:
            time.sleep(1)
            print "try again on iteration:"
            continue
        break


    # Get player name
    name = get_player_name(soup)
    name = name.encode('utf8')
    print(name)
    NAMES.append(name)
  
    # Get Birth Data  
    born = get_player_birth(soup)
    born = born.strip()
    BIRTH.append(born)
    BIRTH = map(lambda s: s.strip(), BIRTH)
    
    # Get Player Debut
    debut = get_player_debut(soup)
    DEBUT.append(debut)
    DEBUT = map(lambda s: s.strip(), DEBUT)

    # Get Player Position    
    position = get_player_position(soup)
    POSITION.append(position)
    POSITION = map(lambda s: s.strip(), POSITION)
    
    # Get Player Stats
    stats = get_stats(soup)
    STATS.append(stats)

# Currently only care about year of debut, so we strip this out
DEBUT_YEAR = extract_debutyear(DEBUT)
Birth_City = extract_birthplace(BIRTH)
Birth_Month = extract_birthmonth(BIRTH)
Birth_Year = extract_birthyear(BIRTH)

print('Retrieving Statistics took %d seconds' % (time.time() - start_time))

#-------------------------------------------------------------#
# 4. Geocode
#    Find birth country given city using geolocation.
#    Try again when there is an exception (usually a TimedOut exception).
#-------------------------------------------------------------#

print('Starting to Geocode....')
start_time = time.time() 				# Start timer for this country iteration

BIRTH_COUNTRY=[]
for i in range(len(Birth_City)):
    city = Birth_City[i]
    print(NAMES[i])
    print(city)
    while True:
        try:
            time.sleep(1)
            birth_country = get_country(city)
            BIRTH_COUNTRY.append(birth_country)
        except:
            time.sleep(1)
            print "try again on iteration:" + str(i)
            continue
        break
        
print('Geocoding took %d seconds' % (time.time() - start_time))

#-------------------------------------------------------------#
# 4. Tidy
#-------------------------------------------------------------#

# Take the first country as most likely (For each player, COUNTRY_STRINGS contains a number of different posibilities)
likely_country = []
for row in BIRTH_COUNTRY:
    if row is not None:
        x=row[0]
    else:
        x=row
    likely_country.append(x)

# Separate each string using the comma separator
odie=[]
for item in likely_country:
    if item is not None:
        x = item.split(',')
    else:
        x = "Missing"
    odie.append(x)

# Extract country strings into more meaningful format
birth_country = extract_birth_country(odie,0)
birth_country1 = extract_birth_country(odie,1)
birth_country2 = extract_birth_country(odie,2)
birth_country3 = extract_birth_country(odie,3)
birth_country = ['NA' if x is None else x.encode('utf-8') for x in birth_country]
birth_country1 = ['NA' if x is None else x.encode('utf-8') for x in birth_country1]
birth_country2 = ['NA' if x is None else x.encode('utf-8') for x in birth_country2]
birth_country3 = ['NA' if x is None else x.encode('utf-8') for x in birth_country3]

# Gather all data points into a dataframe    
d = {'Name' : NAMES,'Debut' : DEBUT_YEAR,'Position':POSITION,
     'Matches':stat_extract(STATS,'Mat'),'Wins':stat_extract(STATS,'Won'),
    'Losses':stat_extract(STATS,'Lost'),'Draws':stat_extract(STATS,'Draw'),
	 'Tries':stat_extract(STATS,'Tries'),'Points':stat_extract(STATS,'Pts'),
	'BirthMonth':Birth_Month, 'BirthYear':Birth_Year,"City":Birth_City,
 'Bcountry':birth_country,'Bcountry1':birth_country1,'Bcountry2':birth_country2,'Bcountry3':birth_country3}
			
d = pd.DataFrame(d)
d['Team'] = np.asarray(df['team'])
d['Links'] = np.asarray(df[0])

d[d.isnull()] = np.nan

# Convert relevant numeric variables from string objects
d['Matches']=pd.to_numeric(d['Matches'])
d['Wins']=pd.to_numeric(d['Wins'])
d['Losses']=pd.to_numeric(d['Losses'])
d['Draws']=pd.to_numeric(d['Draws'])
d['Tries']=pd.to_numeric(d['Tries'])
d['Points']=pd.to_numeric(d['Points'])

# Save
d.to_csv('updated_data.csv',index=False)
