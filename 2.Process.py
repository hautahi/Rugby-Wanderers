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
import cPickle
import csv

storage =  "./data/"

COUNTRY = ["England", "Scotland", "Ireland", "Wales", "SouthAfrica","Australia", "NewZealand", "France", "Argentina", "Italy","Samoa","Tonga","Fiji","Japan","Canada","USA"]
#COUNTRY = ["England", "Scotland", "Ireland", "Wales", "SouthAfrica","Australia"]

#-------------------------------------------------------------#
# 2. Define Functions
#-------------------------------------------------------------#

def extract_birthplace(BIRTH):

    # Separate each string using the comma separator
	odie=[]
	for item in BIRTH:
		x = item.split(',')
		odie.append(x)

    # Extract the string after the last comma
	birth_location = []
	for row in odie:
		x = row[-1]
		x = x.strip()
		birth_location.append(x)

	return birth_location

def extract_debutyear(DEBUT):

    # Separate each string using the comma separator
    odie=[]
    for item in DEBUT:
        x = item.split(',')
        odie.append(x)

    # Extract the string after the last comma
    debut_year = []
    for row in odie:
		x = row[-1]
		x = x.strip()
		debut_year.append(x)

    return debut_year

#-------------------------------------------------------------#
# 3. Perform Analysis
#-------------------------------------------------------------#

for country in COUNTRY:

	NAMES = cPickle.load(open(storage + country + "/Names.p","r"))
	BIRTH = cPickle.load(open(storage + country + "/Birth.p","r"))
	DEBUT = cPickle.load(open(storage + country + "/Debut.p","r"))
	POSITION = cPickle.load(open(storage + country + "/Position.p","r"))
	STATS = cPickle.load(open(storage + country + "/Stats.p","r"))

	birth_location = extract_birthplace(BIRTH)
	debut_year = extract_debutyear(DEBUT)

	BIG_MAT=[]
	for i in range(len(NAMES)):
		current = [NAMES[i], str(debut_year[i]), str(POSITION[i]), birth_location[i].encode('utf8'), STATS[i].get('Mat'), STATS[i].get('Won'), STATS[i].get('Tries'), STATS[i].get('Pts')]
		BIG_MAT.append(current)

	# Save as Python object
	cPickle.dump(BIG_MAT,open(storage + country + "/output.p","w+"))

	# Save to txt
	f = open(storage + country + "/output.txt", "w+")
	f.writelines(["%s\n" % item for item in BIG_MAT])
	f.close()
	
	# Save to csv
	resultFile = open(storage + country + "/output.csv",'w+')
	wr = csv.writer(resultFile, dialect='excel')
	wr.writerows(BIG_MAT)
	resultFile.close()




