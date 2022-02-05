library(twitteR)
library(ROAuth)
library(base64enc)
library(httpuv)
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)


#mach_tweets = userTimeline("aaa", n = 1500)
#mach_tweets = userTimeline("bbb", n = 1500)
mach_tweets = searchTwitter('ccc',n=1500,lang="es",resultType="recent")


class(mach_tweets)

str(mach_tweets)

mach_tweets[1:10]



mach_text = sapply(mach_tweets, function(x) x$getText())

mach_text[1]



myCorpus = Corpus(VectorSource(mach_text))

myCorpus

inspect(myCorpus[1])



myCorpus = tm_map(myCorpus, content_transformer(gsub), pattern="\\W", replace=" ")



removeURL <- function(x) gsub("http[^[:space:`]]*","",x)

myCorpus <- tm_map(myCorpus,content_transformer(removeURL))



myCorpus <- tm_map(myCorpus, content_transformer(tolower))



removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*","",x)

myCorpus <- tm_map(myCorpus,content_transformer(removeNumPunct))



myCorpus = tm_map(myCorpus, removePunctuation)

myCorpus = tm_map(myCorpus,removeNumbers)

myCorpus = tm_map(myCorpus,removeWords, stopwords("spanish"))

myCorpus = tm_map(myCorpus,stripWhitespace)



##wordcloud



dtm <- TermDocumentMatrix(myCorpus)



m <- as.matrix(dtm)

v <- sort(rowSums(m),decreasing=TRUE)

d <- data.frame(word = names(v),freq=v)

head(d,10)



set.seed(1234)

png('~/Documents/resultados/se_twitter.png', width=16,height=16, units='cm', res=300)
wordcloud(words = d$word, freq = d$freq, min.freq=1,max.words=100,random.order=FALSE,colors=brewer.pal(8,"Dark2"))
dev.off()
