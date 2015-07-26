# This program uses geopy to find the country of the birth city

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

# Allow user to call the above function using an import command
if __name__ == "__main__":
	pass

#-------------------------------------------------------------#
# 3. Split country strings
#-------------------------------------------------------------#

# Loop over each country
for country in COUNTRY:

	print country

	# Load pickled Python objects
	COUNTRY_STRINGS = cPickle.load(open(storage + country + "/birth_countries.p","r"))

	# Find most likely country (For each player, COUNTRY_STRINGS contains a number of different posibilities)
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
		x = row[-1]
		x = x.strip()
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

	birth_country2 = []
	for row in odie:
		if len(row)>2:
			x = row[-3]
			x=x.strip()
		else:
			x = "Missing"
		birth_country2.append(x)
		
#-------------------------------------------------------------#
# 4. Combine data
#-------------------------------------------------------------#

# Loop over each country
for country in COUNTRY:

	print country

	BIG_MAT = []
	for i in range(len(birth_country)):
		current = [birth_country[i], birth_country1[i], birth_country2[i]]
		BIG_MAT.append(current)

	HI=[]
	for i in range(len(birth_country)):
		current = [birth_country[i].encode('utf8'), birth_country1[i].encode('utf8'), birth_country2[i].encode('utf8')]
		HI.append(current)

	# Save as Python object
	obj = open(storage + country + "/country.p","w+")
	cPickle.dump(BIG_MAT,obj)
	obj.close()

	# Save to txt
	f = open(storage + country + "/country.txt", "w+")
	f.writelines(["%s\n" % item for item in BIG_MAT])
	f.close()

	f = open(storage + country + "/country1.txt", "w+")
	f.writelines(["%s\n" % item for item in HI])
	f.close()

	# Save to csv
	f = open(storage + country + "/country.csv",'w+')
	wr = csv.writer(f, dialect='excel')
	wr.writerows(HI)
	f.close()
