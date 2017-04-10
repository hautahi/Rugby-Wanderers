# This program "cleans" the resulting dataset from the Python files.

library(dplyr)

# Load data created from Python
original <- read.csv("../1.webscrape/scraped_data.csv",stringsAsFactors = F)
newupdate <- read.csv("updated_data.csv",stringsAsFactors = F)

# Perform a full join
full <- original %>% full_join(newupdate,by="Links")

# Get updated original players data
update_original <- full %>% filter(!is.na(Name.x),!is.na(Name.y))
names(update_original) <- gsub(".y", "", names(update_original), fixed = TRUE)
update_original <- update_original[names(original)]

# Extract New Players
update_new <- full %>% filter(is.na(Name.x))
names(update_new) <- gsub(".x", "", names(update_new), fixed = TRUE)
update_new <- update_new[names(original)]

# Update data for originals
id <- !(original$Links %in% newupdate$Links)
d <- original[id,]
d <- rbind(d,update_original)

# Combine
d <- rbind(d,update_new)

# Save
write.csv(d,"merged_update.csv",row.names = F)
