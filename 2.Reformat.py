# The initial webscrape placed both birthdate and birthplace in the same file.
# In the cases where both were recorded, they were separated by commas, with birthdate first
# This program extracts the last string after the last column (where the birthplace should be) and writes this to another file.
# It also separates out the year of debut from the other details of the debut.

# Author: Hautahi Kingi
# Date: 5 June 2015

#-------------------------------------------------------------#
# 1.  Setup
#-------------------------------------------------------------#

print "Code is Working..."

import re
import numpy as np

COUNTRY = ["England", "Scotland", "Ireland", "Wales", "SouthAfrica","Australia", "NewZealand", "France", "Argentina", "Italy","Samoa","Tonga","Fiji","Japan","Canada","USA"]

def extract_birthplace(country):
    # Open Unformatted Birth Data
    with open('./data/' + country + '/birth.txt') as f:
        content = f.readlines()
	content=map(lambda s: s.strip(), content)

    # Separate each string using the comma separator
	odie=[]
    for item in content:
        x = item.split(',')
        odie.append(x)

    # Extract the string after the last comma
    birth_location = []
    for row in odie:
        birth_location.append(row[-1])

    return birth_location

def extract_debutyear(country):
    # Open Unformatted Debut Data
    with open('./data/' + country + '/debut.txt') as f:
        content = f.readlines()
	content=map(lambda s: s.strip(), content)

    # Separate each string using the comma separator
	odie=[]
    for item in content:
        x = item.split(',')
        odie.append(x)

    # Extract the string after the last comma
    debut_year = []
    for row in odie:
        debut_year.append(row[-1])

    return debut_year

for country in COUNTRY:
    birth_location = extract_birthplace(country)
    debut_year = extract_debutyear(country)
    f = open('./data/' + country + "/birthplaces.txt", "w+")
    f.write("\n".join(x.encode('utf8') for x in birth_location))
    f.close()
    f = open('./data/' + country + "/debut_year.txt", "w+")
    f.write("\n".join(x.encode('utf8') for x in debut_year))
    f.close()
