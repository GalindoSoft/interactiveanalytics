#### load the libraries used for the discussion
install.packages("twitteR")
install.packages("sqldf")
install.packages("XML")
install.packages("RCurl") # cURL interface adapted in R


#==============================================================================
# Read in already existing data from the web
#==============================================================================

##### read in a CSV dataset from yahoo finance
yahoo <- read.csv("http://ichart.finance.yahoo.com/table.csv?s=AAPL&a=08&b=7&c=1984&d=10&e=28&f=2011&g=w&ignore=.csv",
                  header=T, stringsAsFactors=F)

dim(yahoo) # check the rows/columns
head(yahoo, n=5) # look at the first 5 rows
str(yahoo) # have R tell us the details of the 
plot(yahoo[,7], type="l")  # data are reverse order


### fix the data to make a plot
yahoo$Date <- as.Date(yahoo$Date) # tell R that this column is a Date
yahoo.2 <- yahoo[order(yahoo$Date),] # sort the data Ascending order
plot(x=yahoo.2$Date, y=yahoo.2[,7], type="l",
     xlab="Date", ylab="Adjusted Close", 
     main="Weekly Adjusted Closing Price for Apple (AAPL)") # plot the data



#==============================================================================
# Read in HTML tables
# http://stackoverflow.com/questions/4393780/scraping-a-wiki-page-for-the-periodic-table-and-all-the-links
# http://stackoverflow.com/questions/1395528/scraping-html-tables-into-r-data-frames-using-the-xml-package
#==============================================================================

# lets parse NHL data
library(XML)
URL <- paste("http://www.hockey-reference.com/leagues/NHL_", 
  		2011, "_skaters.html", sep="")
tables <- readHTMLTable(URL) # parses all of the tables for us
ds.skaters <- tables$stats # if the table is named (View Source Code), can reference by name
dim(ds.skaters)



#==============================================================================
# Collect data from twitter
#==============================================================================

library(twitteR)
rstats <- searchTwitter("#rstats", n=1500) #searches twitter for the last 1500 tweets
length(rstats) # but only searches back a week or so
mode(rstats) # not a data frame, so we need to convert it to rows/columns
rstats.df <- twListToDF(rstats)
dim(rstats.df)
colnames(rstats.df) # print the column names
length(unique(rstats.df$screenName)) # how many different twitter users
install.packages("sqldf") # install a library to use SQL-like commands
library(sqldf)
temp <- rstats.df
twts <- sqldf("SELECT screenName as name, count(*) as tweets FROM temp
              GROUP BY screenName ORDER BY count(*) desc")
head(twts, n=10) # top 10 tweeters about rstats
hist(twts[,2], xlab="# Rstats Tweets", main="")



#==============================================================================
# Social Network Graph of rstats users
# http://www.drewconway.com/zia/?p=1471
#==============================================================================



#==============================================================================
# Streaming twitter using RCURL
#==============================================================================
library(RCurl)
library(rjson)

# set the directory
setwd("C:\\Documents and Settings\\user\\Desktop\\Web Mining Pres")

#### redirects output to a file, but still has problems with getting data back into R!
WRITE_TO_FILE <- function(x) {
     
     if (nchar(x) >0 ) {
          write.table(x, file="Twitter Stream Capture.txt", append=T, row.names=F, col.names=F)
     }
     
}

### windows users will need to get this certificate to authenticate
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

### write the raw JSON data from the Twitter Firehouse to a text file
getURL("https://stream.twitter.com/1/statuses/sample.json", 
       userpwd=USER:PASSWORD,
       cainfo = "cacert.pem", 
       write=WRITE_TO_FILE)