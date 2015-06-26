# This program uses geopy to find the country of the birth city

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

#COUNTRY = ["England", "Scotland", "Ireland", "Wales", "SouthAfrica","Australia", "NewZealand", "France", "Argentina", "Italy","Samoa","Tonga","Fiji","Japan","Canada","USA"]
COUNTRY = ["England"]

#-------------------------------------------------------------#
# 2. Define Functions
#-------------------------------------------------------------#

def	take_col(mat, index):
	col = []
	for row in mat:
		col.append(row[index])
	return col

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
# 3. Grab Country
#-------------------------------------------------------------#

# Loop over each country
for country in COUNTRY:

	print country

	# Load pickled Python objects
	CLEAN_DATA = cPickle.load(open(storage + country + "/output.p","r"))

	# Extract Birth City Data from dataset
	Birth_City = take_col(CLEAN_DATA,3)

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
		
	BIG_MAT = []
	for i in range(len(BIRTH_COUNTRY)):
		current = [BIRTH_COUNTRY[i]]
		current.extend(CLEAN_DATA[i])
		BIG_MAT.append(current)

	# Save as Python object
	obj = open(storage + country + "/birth_countries.p","w+")
	cPickle.dump(BIRTH_COUNTRY,obj)
	obj.close()
