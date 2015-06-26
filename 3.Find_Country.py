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
#import geocoder
from geopy.exc import GeocoderTimedOut

geolocator = Nominatim()

storage =  "./data/"

COUNTRY = [ "Scotland", "Ireland", "Wales", "SouthAfrica","Australia", "NewZealand", "France", "Argentina", "Italy","Samoa","Tonga","Fiji","Japan","Canada","USA"]

#-------------------------------------------------------------#
# 2. Define Functions
#-------------------------------------------------------------#

def	take_col(mat, index):
	col = []
	for row in mat:
		col.append(row[index])
	return col

def get_country(city):
	location = geolocator.geocode(city, timeout=10)
	if location is not None:
		z=location.address
	else:
		z=location
	return z

"""def get_country_google(city):
	location = geocoder.google(city)
	z=location.country
	return z

def get_country1(city):
	location = geocoder.geonames(city)
	z=location.country
	return z
"""

# Allow user to call the above function using an import command
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

	# Gather data into one list
	Birth_City = take_col(CLEAN_DATA,3)

	BIRTH_COUNTRY=[]
	for i in range(len(Birth_City)):
		city = Birth_City[i]
		while True:
			try:
				birth_country = get_country(city)
				#birth_country = get_country1(city)
				#birth_country = get_country_google(city)
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
	obj = open(storage + country + "/output1.p","w+")
	cPickle.dump(BIRTH_COUNTRY,obj)
	obj.close()
