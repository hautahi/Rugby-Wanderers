# The initia

# Author: Hautahi Kingi
# Date: 5 June 2015

#-------------------------------------------------------------#
# 1.  Setup
#-------------------------------------------------------------#

print "Code is Working..."

import cPickle
import csv

storage =  "./data/"

COUNTRY = ["England","Scotland", "Ireland", "Wales", "SouthAfrica","Australia", "NewZealand", "France", "Argentina", "Italy","Samoa","Tonga","Fiji","Japan","Canada","USA"]

#-------------------------------------------------------------#
# 2. Define Functions
#-------------------------------------------------------------#

#-------------------------------------------------------------#
# 3. Clean Data
#-------------------------------------------------------------#

for country in COUNTRY:

	print country

	# Load pickled Python objects
	OUTPUT = cPickle.load(open(storage + country + "/output.p","r"))
	BIRTH_COUNTRY =  cPickle.load(open(storage + country + "/country.p","r"))

	BIG_MAT = []
	for i in range(len(OUTPUT)):
		current = OUTPUT[i]+BIRTH_COUNTRY[i]
		BIG_MAT.append(current)

	HI=[]
	for i in range(len(BIG_MAT)):
		current = [x.encode('utf-8') for x in BIG_MAT[i] if x is not None]
		HI.append(current)

	# Save as Python object
	obj = open(storage + country + "/final.p","w+")
	cPickle.dump(BIG_MAT,obj)
	obj.close()

	# Save to txt
	f = open(storage + country + "/final.txt", "w+")
	f.writelines(["%s\n" % item for item in BIG_MAT])
	f.close()

	# Save to csv
	resultFile = open(storage + country + "/final.csv",'w+')
	wr = csv.writer(resultFile, dialect='excel')
	wr.writerows(HI)
	resultFile.close()
