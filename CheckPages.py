# Importación de librerías
from GoogleNews import GoogleNews
from newspaper import Article
from newspaper import Config
import pandas as pd
import nltk
from googletrans import Translator as T
from translate import Translator
import sys

# Esta configuración facilita el acceso en caso de existir errores 403
# mientras se hace el parseo del articulo descargado 


nltk.download('punkt')

user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'
config = Config()
config.browser_user_agent = user_agent

# Consulta de noticias a través de la API de Google News
# googlenews=GoogleNews(start='07/04/2021',end='07/11/2021')
googlenews.search('Ricardo Monreal')
googlenews.search(sys.argv[1])
result=googlenews.result()
df=pd.DataFrame(result)
print(df.head())

# Iteramos por las diferentes páginas de resultados, para obtener al menos 20 noticias
for i in range(2,20):
    googlenews.getpage(i)
    result=googlenews.result()
    df=pd.DataFrame(result)
list=[]
articulos = []
noticiasen = []
translator= Translator(to_lang="en")

# Guardamos en una lista los resultados de cada noticia
for ind in df.index:
    dict={}
    article = Article(df['link'][ind],config=config)
    try:
        article.download()
        article.parse()
        article.nlp()
        dict['Date']=df['date'][ind]
        dict['Media']=df['media'][ind]
        dict['Title']=article.title
        dict['Article']=article.text
        dict['Summary']=article.summary 
        traduccion = translator.translate(article.text)
        noticiasen.append(traduccion)  
        articulos.append(article.text)
        list.append(dict)    
    except:
        print ("No pudo descargarse el artículo ", df['link'][ind])



# Traducimos al inglés las noticias para analizar los sentimientos en R
trans = T()
noticiasengoogle = []
try:
    traducciones = trans.translate(articulos, dest='en')
    for traduccion in traducciones:
        noticiasengoogle.append(traduccion.text)
    # Guardammos las noticias traducidas en inglés de la traducción de google
    news_df=pd.DataFrame(noticiasengoogle)
    news_df.to_excel("fuentes/noticiasen.xlsx")    
except:
    # Guardammos las noticias traducidas en inglés de la traducción de python
    print("Google no pudo traducir")
    news_df=pd.DataFrame(noticiasen)
    news_df.to_excel("noticiasen.xlsx")


# Guardamos las noticias en español, este es el archivo original con el resto de información
news2_df=pd.DataFrame(list)
news2_df.to_excel("articles.xlsx")