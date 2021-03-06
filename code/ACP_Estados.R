################################################################################
# Tarea de ACP evaluable donde se ha escogido el Problema 3
# 
# En el conjunto constituido por 34 estados del mundo se han observado 11 
# variables cuyos resultados se recogen en el archivo estados.sav. 
# Estas variables se han estandarizado, pues están tomadas 
# con unidades de medida muy diferentes. 
# En este caso, se plantea la reducción del número de variables mediante un ACP.
# Nota: para este problema se pide el informe con los datos estandarizados. 
# Aunque la variable Estado no se incluirá para la reducción de la dimensión, 
# sí se pide, en la medida de lo posible, que los distintos gráficos la incluyan 
# para tener una visión más realista desde un punto de vista comparativo entre estados
################################################################################

# Directorio de trabajo
getwd()
 
# -------------------------------------- #
# PASO 0: cargar datos                   
# -------------------------------------- #
library(foreign)
data <- read.spss("estados.sav", to.data.frame=TRUE)
head(data, 34)
data[11, "PAIS"] <- "espania"
head(data, 34)

library(dplyr)
introduce(data)

# 11 variables observadas en 34 Estados del mundo
# Eliminamos la primera columna del data.frame (PAIS) ya que no aporta nada al ACP 
datos_pca<-data[,-1]
row.names(datos_pca) = as.character(data$PAIS)
# Para añadirlo de nuevo, 
summary(datos_pca)

library(DataExplorer)
plot_missing(datos_pca)
plot_histogram(datos_pca)

#Dado que las variables presentan unidades de medida muy diversas así como varianzas muy
#distintas, se han estandarizado previamente para evitar que algunas puedan anular o
#minimizar los efectos de otras. El análisis ACP se basará, por tanto, en dichas variables. O
#lo que es igual, ACP de matriz de correlaciones de variables sin estandarizar. 

# Guardo los datos originales porque la variable datos_pca va a cambiar a lo 
# largo del an?lisis
datos_originales<-datos_pca

# For data frames, a convenient shortcut to compute the total missing values in
# each column is to use colSums():
colSums(is.na(datos_pca))

# Se observa que en los datos hay algunos valores perdidos (NA). Hay que hacer 
# un tratamiento detallado de estos valores perdidos. En este caso los vamos a
# sustituir por la media.
not_available<-function(data,na.rm=F){
  data[is.na(data)]<-mean(data,na.rm=T)
  data
}

datos_pca$ZTLIBROP<-not_available(datos_pca$ZTLIBROP)

colSums(is.na(datos_pca))

# -------------------------------------- #
# PASO 1: ¿tiene sentido un ACP?
# -------------------------------------- #
cor(datos_pca)
plot_correlation(datos_pca)

#valores bajos son indicio de existencia de correlaciones entre variables 
det(cor(datos_pca ))

#Exploración de los datos
plot(datos_pca)

#cor(datos_pca,use = "pairwise") #Hay algún dato missing, por lo usamos la opción “pairwise”
#round(cor(datos_pca,use = "pairwise"),3)

# Observando la matriz de datos existe correlación importante entre algunas
# variables
cor(datos_pca$ZPSERVI,datos_pca$ZPOBURB)
cor(datos_pca$ZESPVIDA,datos_pca$ZPOBURB)

# El contraste de esfericidad de Bartlett permite comprobar si las correlaciones
# son distintas de 0 de modo significativo. La hipótesis nula es que det(R)=1
# La función "cortest.bartlett" del paquete "pysch" reliza este test.
# Carga del paquete "psych"
library(psych)
# Se normalizan los datos
#datos_normalizados<-scale(datos_pca)
# Se hace el test de esfericidad
cortest.bartlett(cor(datos_pca), n = 34)

# ------------------------------------------ #
# Paso 2: EDA                 
# ------------------------------------------ #
# El objetivo es el de localizar outliers que puedan dar lugar a resultados
# erróneos ya que el ACP es muy sensible a valores extremos. Un diagrama de 
# cajas puede dar esta primera información.
# Vemos que algunas variables presentan outliers

par(cex.axis=0.5) # is for x-axis
boxplot(datos_pca,main="EDA",
        ylab="z-values",
        ylim=c(-3,5),
        las=2,
        col=c(1:11))
# Al obtener el gr?fico con estos datos se observa que muchas variables
# presentan outliers
# ZPOBDENS, ZTEJERCI, ZTENERGI presentan outliers

# Los outliers deben ser tratados de forma independiente por el investigador, 
# de modo que para el ACP es necesario eliminarlos
# La función outlier definida como sigue elimina los outliers sustituyéndolos
# por los promedios del resto de valores.
outlier<-function(data,na.rm=T){
  H<-1.5*IQR(data)
  data[data<quantile(data,0.25,na.rm = T)-H]<-NA
  data[data>quantile(data,0.75, na.rm = T)+H]<-NA
  continue<-any(is.na(data)) 
  data[is.na(data)]<-mean(data,na.rm=T)
  data[is.na(data)]<-mean(data,na.rm=T)
  data
}

# A continuación aplicamos esta función las variables con outliers
datos_pca$ZPOBDENS<-outlier(datos_pca$ZPOBDENS)
datos_pca$ZTEJERCI<-outlier(datos_pca$ZTEJERCI)
datos_pca$ZTENERGI<-outlier(datos_pca$ZTENERGI)

# Comparamos los datos originales y los arreglados 
par(mfrow=c(1,2))
# Boxplot de los datos originales
boxplot(datos_originales,main="Datos originales",
        ylab="z-values",
        ylim=c(-3,5),
        las=2,
        col=c(1:11))
# Boxplot de los datos corregidos.
boxplot(datos_pca,main="Datos sin outliers",
        ylab="z-values",
        ylim=c(-3,5),
        las=2,
        col=c(1:11))

plot_boxplot(datos_pca, by = "ZPOBURB")
# ----------- #
# Paso 3: ACP #
# ----------- #

PCA<-prcomp(datos_pca, scale=T, center = T)
# El el campo "rotation" del objeto "PCA" es una matrix cuyas columnas
# son los coeficientes de las componentes principales, es decir, el
# peso de cada variable en la correspondiente componente principal
#Los vectores propios de la matriz de correlaciones son las
#columnas de la matriz rotation
# Matriz de vectores propios
PCA$rotation

# Valores propios o varianzas de las componentes
summary(PCA)$sdev^2

# En el campo "sdev" del objeto "PCA" y con la función summary aplicada
# al objeto, obtenemos información relevante: desviaciones típicas de 
# cada componente principal, proporción de varianza explicada y acumulada.
PCA$sdev
summary(PCA) 
screeplot(PCA)

# Las 3 primeras componentes tienen varianza superior a 1, tal como muestra el resultado. 
# La cuarta componente presenta un valor muy próximo a 1 
# (con un valor propio o varianza igual a 0.92): 

# Instalaci?n del paquete desde un repositorio en caso de no estar instalado
#install.packages("ggplot2")
# Carga del paquete "ggplot2" 
library("ggplot2")

# Cada k-ésimo valor propio o autovalor (k=1, ..,11) se interpreta como la parte de la
# varianza que el k-ésimo eje principal (o sea, la correspondiente componente principal)
#explica. Y el cociente autovalor / p, como la proporción correspondiente a dicha
# componente; muestra, en consecuencia, la importancia de esta componente en el conjunto.
# En particular, para la primera componente tenemos: 6,103 / 11 = 0,55478 (véase % de la
# varianza en Varianza total explicada) 

# El siguiente gráfico muestra la proporción de varianza explicada
varianza_explicada <- PCA$sdev^2 / sum(PCA$sdev^2)
ggplot(data = data.frame(varianza_explicada, pc = 1:11),
       aes(x = pc, y = varianza_explicada, fill=varianza_explicada )) +
  geom_col(width = 0.3) +
  scale_y_continuous(limits = c(0,0.6)) + theme_bw() +
  labs(x = "Componente principal", y= " Proporción de varianza")

# El siguiente gr?fico muestra la proporci?n de varianza explicada
varianza_acum<-cumsum(varianza_explicada)
ggplot( data = data.frame(varianza_acum, pc = 1:11),
        aes(x = pc, y = varianza_acum ,fill=varianza_acum )) +
  geom_col(width = 0.5) +
  scale_y_continuous(limits = c(0,1)) +
  theme_bw() +
  labs(x = "Componente principal",
       y = "Proporción varianza acumulada")



# -------------------------------------------------------------- #
# Paso 4: selecci?n del n?mero de componentes principales ?ptimo #
# -------------------------------------------------------------- #
# Existen diferentes m?todos:
# 1.- M?todo del codo (Cuadras, 2007). Ejercicio: buscar informaci?n (voluntario)
# 2.- A criterio del investigador que elige un porcentaje m?nimo de varianza explicada
# por las componentes principales (no es fiable porque puede dar m?s de las necesarias.
# 3.- En este caso se utiliza la regla de Abdi et al. (2010). Se promedia las varianzas
# explicadas por la componentes principales y se selecciona aquellas cuya proporci?n de 
# varianza explicada supera la media.
# En este caso se eligen tan solo tres direcciones principales tal y como se puede ver
PCA$sdev^2
mean(PCA$sdev^2)

ggplot( data = data.frame(varianza_acum, pc = 1:11),
        aes(x = pc, y = varianza_acum ,fill=varianza_acum )) + 
  geom_line(size = 1.5) + 
  geom_point(size=3, fill="black") +
  scale_y_continuous(limits = c(0,1)) + 
  theme_bw() +
  labs(x = "Componente principal", y = "Proporcion de varianza acumulada")

# -------------------------------------------------------------- #
# Paso 5: Representaci?n gr?fica de las componentes principales  #
# -------------------------------------------------------------- #

# El paquete "factoextra" permite la representaci?n de las componentes principales
# junto con las variables y observaciones del an?lisis de componentes principales.
t(round(PCA$x[,1:3],3))

cor(datos_pca,predict(PCA)[,1:3])

# Instalaci?n del paquete desde un repositorio en caso de no estar instalado
# El siguiente paquete requiere tener al menos la vesri?n de R 4.0.x
# install.packages("factoextra")
# Carga del paquete "factorextra" si est? instalado
library("factoextra")

# Esto produce una comparativa entre la primera y segunda componente principal analizando 
# que variables tienen m?s peso para la definici?n de cada componente principal
fviz_pca_var(PCA,
             repel=TRUE,col.var="cos2",
             legend.title="Distancia")+theme_bw()

# Esto produce una comparativa entre la primera y tercera componente principal analizando 
# que variables tienen m?s peso para la definici?n de cada componente principal
fviz_pca_var(PCA,axes=c(1,3),
             repel=TRUE,col.var="cos2",
             legend.title="Distancia")+theme_bw()

# Esto produce una comparativa entre la segunda y tercera componente principal analizando 
# que variables tienen m?s peso para la definici?n de cada componente principal
fviz_pca_var(PCA,axes=c(2,3),
             repel=TRUE,col.var="cos2",
             legend.title="Distancia")+theme_bw()

# Análisis con extracción de 3 componentes
#Sólo tres componentes capturan una variabilidad total del 81% (columna % acumulado).
#Esto supone que se puede reducir la dimensionalidad de los datos al pasar de 11 variables
#observadas a trabajar con sólo 3, sin distorsionar demasiado la información inicial
#(habrá 19% de variabilidad en los datos originales del que las tres componentes extraídas no
#pueden dar cuenta). En sólo 3 dimensiones puede registrarse el 81% de la variabilidad
#original, de modo que los tres factores o componentes explican el 81% de la variabilidad
#total.
#En principio, se prescinde de las componentes asociadas a los valores propios con
#autovalores inferiores a 1. No obstante, dado que el cuarto autovalor está próximo a 1,
#convendrá examinar también las posibles ventajas e inconvenientes de su inclusión
#Aumentar el número de componentes supone aumentar la dimensionalidad de la información resumida en
#las componentes. No obstante, a veces, un subgrupo de variables importantes podría no quedar bien
#representado si se omite una componente que recoge la variabilidad del mismo. 

# Es posible tambi?n representar las observaciones de los objetos junto con las componentes 
# principales mediante la orden "contrib" de la funci?n "fviz_pca_ind", as? como identificar
# con colores aquellas observaciones que mayor varianza explican de las componentes principales

# Observaciones en la primera y segunda componente principal
fviz_pca_ind(PCA,col.ind = "contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel=TRUE,legend.title="Contrib.var")+theme_bw()

# Observaciones en la primera y tercera componente principal
fviz_pca_ind(PCA,axes=c(1,3),col.ind = "contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel=TRUE,legend.title="Contrib.var")+theme_bw()

# Observaciones en la segunda y tercera componente principal
fviz_pca_ind(PCA,axes=c(2,3),col.ind = "contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel=TRUE,legend.title="Contrib.var")+theme_bw()

# Representaci?n conjunta de variables y observaciones
# que relaciona visualmente las posibles relaciones entre las
# observaciones, las contribuciones de los individuos a las varianzas de las componentes
# y el peso de las variables en cada componentes principal

# Variables y observaciones en las 1 y 2 componente principal
fviz_pca(PCA,
         alpha.ind ="contrib", col.var = "cos2",col.ind="seagreen",
         gradient.cols = c("#FDF50E", "#FD960E", "#FD1E0E"),
         repel=TRUE,
         legend.title="Distancia")+theme_bw()

# Variables y observaciones en las 1 y 3 componente principal
fviz_pca(PCA,axes=c(1,3),
         alpha.ind ="contrib", col.var = "cos2",col.ind="seagreen",
         gradient.cols = c("#FDF50E", "#FD960E", "#FD1E0E"),
         repel=TRUE,
         legend.title="Distancia")+theme_bw()

# Variables y observaciones en las 2 y 3 componente principal
fviz_pca(PCA,axes=c(2,3),
         alpha.ind ="contrib", col.var = "cos2",col.ind="seagreen",
         gradient.cols = c("#FDF50E", "#FD960E", "#FD1E0E"),
         repel=TRUE,
         legend.title="Distancia")+theme_bw()



# Por ?ltimo, ya que el objeto de este estudio era reducir la dimensi?n de las variables
# utilizadas, es posible obtener las coordenadas de los datos originales tipificados en el
# nuevo sistema de referencia.
# De hecho lo tenemos almacenado desde que utilizamos la funci?n prcomp para crear la variable PCA

head(PCA$x,n=34)

