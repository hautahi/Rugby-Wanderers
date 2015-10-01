# This program gathers all relevant statistics into one data file
# If birthplace has more that one possible country, it takes the first country.


# Author: Hautahi Kingi
# Date: 22 June 2015

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

def hasNumbers(inputString):
	return any(char.isdigit() for char in inputString)

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
#		x = row[1]
		x = x.strip()
		birth_year.append(x)

	return birth_year


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

# Allow user to call the above function using an import command
if __name__ == "__main__":
	pass


# Loop over each country
for country in COUNTRY:

	print country

	# Load pickled Python objects
	COUNTRY_STRINGS = cPickle.load(open(storage + country + "/birth_countries.p","r"))
	NAMES = cPickle.load(open(storage + country + "/Names.p","r"))
	DEBUT = cPickle.load(open(storage + country + "/Debut.p","r"))
	POSITION = cPickle.load(open(storage + country + "/Position.p","r"))
	STATS = cPickle.load(open(storage + country + "/Stats.p","r"))
	BIRTH = cPickle.load(open(storage + country + "/Birth.p","r"))

	# Currently only care about year of debut, so we strip this out
	debut_year = extract_debutyear(DEBUT)
	Birth_City = extract_birthplace(BIRTH)
	Birth_Month = extract_birthmonth(BIRTH)
	Birth_Year = extract_birthyear(BIRTH)

#-------------------------------------------------------------#
# 3. Split country strings
#-------------------------------------------------------------#


	# Take the first country as most likely (For each player, COUNTRY_STRINGS contains a number of different posibilities)
	likely_country = []
	for row in COUNTRY_STRINGS:
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

	# Extract the string after the last comma and strip any spaces
	birth_country = []
	for row in odie:
			if len(row)>0:
				x = row[-1]
				x = x.strip()
			else:
				x="Missing"
			birth_country.append(x)

	# Extract the string before the last comma and strip any spaces (use this to differentiate between the UK countries)
	birth_country1 = []
	for row in odie:
		if len(row)>1:
			x = row[-2]
			x=x.strip()
		else:
			x = "Missing"
		birth_country1.append(x)

	# Do the same for next comma, because formatting sometimes places UK country here 
	birth_country2 = []
	for row in odie:
		if len(row)>2:
			x = row[-3]
			x=x.strip()
		else:
			x = "Missing"
		birth_country2.append(x)

	# Do the same for next comma, because formatting sometimes places UK country here 
	birth_country3 = []
	for row in odie:
		if len(row)>3:
			x = row[-4]
			x=x.strip()
		else:
			x = "Missing"
		birth_country3.append(x)
		
#-------------------------------------------------------------#
# 4. Combine data
#-------------------------------------------------------------#

# Country Specific
	BIG_MAT = []
	for i in range(len(COUNTRY_STRINGS)):
		y =	[NAMES[i], str(debut_year[i]), str(POSITION[i]), STATS[i].get('Mat'), STATS[i].get('Won'), STATS[i].get('Lost'),STATS[i].get('Draw'), STATS[i].get('Tries'), STATS[i].get('Pts'), Birth_City[i].encode('utf8'), birth_country[i], birth_country1[i], birth_country2[i], birth_country3[i],str(Birth_Month[i]),str(Birth_Year[i])]
		BIG_MAT.append(y)

	HI=[]
	for i in range(len(BIG_MAT)):
		current = ['NA' if x is None else x.encode('utf-8') for x in BIG_MAT[i]]
		HI.append(current)

#-------------------------------------------------------------#
# 4. Save
#-------------------------------------------------------------#

FINAL=[]
for country in COUNTRY:

	print country

	# Load pickled Python objects
	data = cPickle.load(open(storage + country + "/final.p","r"))

	for row in data:
		x=row+[country]
		FINAL.append(x)

FINAL_FORMAT=[]
for i in range(len(FINAL)):
	current = ['NA' if x is None else x.encode('utf-8') for x in FINAL[i]]
	FINAL_FORMAT.append(current)


# Save to csv
f = open("complete.csv",'w+')
wr = csv.writer(f, dialect='excel')
wr.writerows(FINAL_FORMAT)
f.close()
