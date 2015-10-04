# This program uses the geopy package to find the countries that match the birth city
# It takes all the countries that match, and saves them as a pickled Python object

# Author: Hautahi Kingi
# Date: 22 June 2015

#-------------------------------------------------------------#
# 1.  Setup
#-------------------------------------------------------------#

print "Code is Working..."

import cPickle
import csv
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut

geolocator = Nominatim()

storage =  "./data/"

COUNTRY = ["England", "Scotland", "Ireland", "Wales", "SouthAfrica","Australia", "NewZealand", "France", "Argentina", "Italy","Samoa","Tonga","Fiji","Japan","Canada","USA"]
#COUNTRY = ["England"]

#-------------------------------------------------------------#
# 2. Define Functions
#-------------------------------------------------------------#

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

# Allow user to call the above functions using an import command
if __name__ == "__main__":
	pass

#-------------------------------------------------------------#
# 3. Grab Countries
#-------------------------------------------------------------#

# Loop over each country
for country in COUNTRY:

	print country

	# Load pickled Python objects
	BIRTH = cPickle.load(open(storage + country + "/Birth.p","r"))

	# Extract Birth City from Birth Data
	Birth_City = extract_birthplace(BIRTH)

	# Find birth country given city using geolocation. Try again when there is an exception (usually a TimedOut exception).
	BIRTH_COUNTRY=[]
	for i in range(len(Birth_City)):
		city = Birth_City[i]
		while True:
			try:
				birth_country = get_country(city)
				BIRTH_COUNTRY.append(birth_country)
			except:
				print "try again on iteration:" + str(i)
				continue
			break
		
	# Save as Python object
	obj = open(storage + country + "/birth_countries.p","w+")
	cPickle.dump(BIRTH_COUNTRY,obj)
	obj.close()
