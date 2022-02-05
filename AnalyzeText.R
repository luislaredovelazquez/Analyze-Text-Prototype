# Importamos librerias

library(readxl)
library(tidytext)
library(dplyr)
library(ggplot2)
library(wordcloud)
library(reshape2)
library("RColorBrewer")

# Leemos archivo y lo transformamos a formato tidy (Especificar ruta completa)

tidynews <- read_excel("~/Documents/Bkp/noticiasen.xlsx") %>%
  unnest_tokens(word, '0')

# Agregamos las stop_words en inglés

data(stop_words)
tidynews <- tidynews %>%
  anti_join(stop_words)

#Agregamos stopwords en caso de que aparezcan, en caso de ciberseguridad "nube"

custom_stop_words <- bind_rows(tibble(word = c("NA"),  
                                      lexicon = c("custom")),
                               stop_words)

custom_stop_words

# Contamos y ordenamos

tidynews %>%
  count(word, sort = TRUE)

# Obtenemos gr?fica de frecuencia
# (tenemos que calcular bien el filtro, para que aparezca informaci?n)

png('~/Documents/resultados/frecuencia.png', width=16,height=16, units='cm', res=300)
tidynews %>%
  anti_join(custom_stop_words) %>%
  count(word, sort = TRUE) %>%
  filter(n > 25) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word)) +
  geom_col() +
  labs(y = NULL)
dev.off()



#Buscamos sentimientos positivos usando nrc

nrc_joy <- get_sentiments("nrc") %>%
  filter(sentiment == "joy")

tidynews %>%
  inner_join(nrc_joy) %>%
  count(word, sort = TRUE)

#Buscamos sentimientos usando bing

bing_word_counts <- tidynews %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  ungroup()

bing_word_counts

#Analizamos los sentimientos en las noticias

png('~/Documents/resultados/distribucionSentimientos.png', width=16,height=16, units='cm', res=300)
bing_word_counts %>%
  anti_join(custom_stop_words) %>%
  group_by(sentiment) %>%
  top_n(10) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(x = "Contribucion al sentimiento",
       y = NULL)
dev.off()



# Agregamos visualizaciones de nube, aca podemos iterar entre stop_words
# y custom_stop_words
png('~/Documents/resultados/sentimientos_wc.png', width=16,height=16, units='cm', res=300)
tidynews %>%
  anti_join(custom_stop_words) %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 200, rot.per=0.35,
                 fixed.asp=TRUE, size = .5,
                 colors=brewer.pal(8, "Dark2")))
dev.off()

# Ordenamos por sentimientos positivos y negativos
png('~/Documents/resultados/PositivosNegativos.png', width=16,height=16, units='cm', res=300)
tidynews %>%
  anti_join(custom_stop_words) %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("gray40", "gray80"),
                   max.words = 100)
dev.off()
