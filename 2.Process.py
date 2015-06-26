# The initial webscrape saved data as pickled Python objects
# This program cleans that data into a readbale format
# It also extracts the birthplace from the full birth data as well as the debut year from the full debut data

# Author: Hautahi Kingi
# Date: 5 June 2015

#-------------------------------------------------------------#
# 1.  Setup
#-------------------------------------------------------------#

print "Code is Working..."

import cPickle
import csv

storage =  "./data/"

COUNTRY = ["England", "Scotland", "Ireland", "Wales", "SouthAfrica","Australia", "NewZealand", "France", "Argentina", "Italy","Samoa","Tonga","Fiji","Japan","Canada","USA"]

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

# Allow user to call the above functions using an import command
if __name__ == "__main__":
	pass

#-------------------------------------------------------------#
# 3. Clean Data
#-------------------------------------------------------------#

for country in COUNTRY:

	# Load pickled Python objects
	NAMES = cPickle.load(open(storage + country + "/Names.p","r"))
	BIRTH = cPickle.load(open(storage + country + "/Birth.p","r"))
	DEBUT = cPickle.load(open(storage + country + "/Debut.p","r"))
	POSITION = cPickle.load(open(storage + country + "/Position.p","r"))
	STATS = cPickle.load(open(storage + country + "/Stats.p","r"))

	# Currently only care about birthplace and year of debut, so we strip this out
	birth_location = extract_birthplace(BIRTH)
	debut_year = extract_debutyear(DEBUT)

	# Gather data into one list
	BIG_MAT=[]
	for i in range(len(NAMES)):
		current = [NAMES[i], str(debut_year[i]), str(POSITION[i]), birth_location[i].encode('utf8'), STATS[i].get('Mat'), STATS[i].get('Won'), STATS[i].get('Tries'), STATS[i].get('Pts')]
		BIG_MAT.append(current)

	# Save as Python object
	obj = open(storage + country + "/output.p","w+")
	cPickle.dump(BIG_MAT,obj)
	obj.close()

	# Save to txt
	f = open(storage + country + "/output.txt", "w+")
	f.writelines(["%s\n" % item for item in BIG_MAT])
	f.close()
	
	# Save to csv
	resultFile = open(storage + country + "/output.csv",'w+')
	wr = csv.writer(resultFile, dialect='excel')
	wr.writerows(BIG_MAT)
	resultFile.close()
