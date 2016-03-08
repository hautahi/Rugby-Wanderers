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
import pandas as pd
import numpy as np

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

def stat_extract(STATS,string):    
    MAT=[]
    for i in range(len(STATS)):
        mat=STATS[i].get(string)
        MAT.append(mat)
    return MAT

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

# Allow user to call the above function using an import command
if __name__ == "__main__":
	pass

#-------------------------------------------------------------#
# 3. Gather data for each country
#-------------------------------------------------------------#

df=pd.DataFrame([])
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

	# Extract country strings into more meaningful format
	birth_country = extract_birth_country(odie,0)
	birth_country1 = extract_birth_country(odie,1)
	birth_country2 = extract_birth_country(odie,2)
	birth_country3 = extract_birth_country(odie,3)
	birth_country = ['NA' if x is None else x.encode('utf-8') for x in birth_country]
	birth_country1 = ['NA' if x is None else x.encode('utf-8') for x in birth_country1]
	birth_country2 = ['NA' if x is None else x.encode('utf-8') for x in birth_country2]
	birth_country3 = ['NA' if x is None else x.encode('utf-8') for x in birth_country3]

	# Create a column indicating the team
	country_col=[]
	for i in range(len(NAMES)):
			country_col.append(country)

	# Gather all data points into a dataframe    
	d = {'Name' : NAMES,'Debut' : debut_year,'Position':POSITION,'Matches':stat_extract(STATS,'Mat'),
	 'Wins':stat_extract(STATS,'Won'),'Losses':stat_extract(STATS,'Lost'),'Draws':stat_extract(STATS,'Draw'),
	 'Tries':stat_extract(STATS,'Tries'),'City':Birth_City, 'Points':stat_extract(STATS,'Pts'),
	'BirthMonth':Birth_Month, 'BirthYear':Birth_Year,"City":Birth_City,'Team':country_col,
	'Bcountry':birth_country,'Bcountry1':birth_country1,'Bcountry2':birth_country2,'Bcountry3':birth_country3}
	df_country = pd.DataFrame(d)
	df_country[df_country.isnull()] = np.nan

	df = df.append(df_country)
		
#-------------------------------------------------------------#
# 4. Finalize data
#-------------------------------------------------------------#

# Convert relevant numeric variables from string objects
df['Matches']=pd.to_numeric(df['Matches'])
df['Wins']=pd.to_numeric(df['Wins'])
df['Losses']=pd.to_numeric(df['Losses'])
df['Draws']=pd.to_numeric(df['Draws'])
df['Tries']=pd.to_numeric(df['Tries'])
df['Points']=pd.to_numeric(df['Points'])

# Save
df.to_csv('scraped_data.csv',index=False)
