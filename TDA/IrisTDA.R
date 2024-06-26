library(TDA)
library(tidyverse)

data(iris)
Xiris <- iris%>%select(Sepal.Length, Petal.Length)
library(plotly)
fig <- plot_ly(data = iris, x = ~Sepal.Length, y = ~Petal.Length, 
               z = ~Sepal.Width,  type = 'scatter3d', mode = 'markers')
fig <- fig %>% layout(title = 'Point Clouda')
fig

Xlim <- c(1, 8)
Ylim <- c(1, 8)
by <- 0.05
Xseq <- seq(Xlim[1], Xlim[2], by = by)
Yseq <- seq(Ylim[1], Ylim[2], by = by)
Grid <- expand.grid(Xseq, Yseq)
par(mfrow = c(1, 2), bg = "gray")
KDE <- kde(X = Xiris, Grid = Grid, h = 0.3)
kNN <- knnDE(X = Xiris, Grid = Grid, k = 60)
# iris_dist <- distFct(X = Xiris, Grid = Grid)
persp(Xseq, Yseq,
      matrix(KDE, ncol = length(Yseq), nrow = length(Xseq)), xlab = "",
      ylab = "", zlab = "", theta = 30, phi = 20, ltheta = 50,
      border = NA, main = "KDE", d = 0.5, scale = FALSE, box = TRUE, col = "brown",
      expand = 3, shade = 0.9)
persp(Xseq, Yseq,
      matrix(kNN, ncol = length(Yseq), nrow = length(Xseq)), xlab = "",
      ylab = "", zlab = "", theta = 30, phi = 20, ltheta = 50,
      border = NA, main = "kNN", d = 0.5, scale = FALSE, box = TRUE, col = "brown",
      expand = 3, shade = 0.9)
# plot(Xiris, col = iris$Species, pch = 19, cex = 1.5)


band <- bootstrapBand(X = Xiris, FUN = kde, Grid = Grid, B = 100,
                      parallel = FALSE, alpha = 0.1, h = 0.3)
# rips diagram
DiagRips <- ripsDiag(
  X = Xiris, maxdimension = 1, maxscale = 1, 
  library = c("GUDHI", "Dionysus"), location = TRUE, printProgress = TRUE)
plot(DiagRips[["diagram"]], main = "Rips Diagram")
# plot(DiagRips[["diagram"]], band = 2 * band[["width"]], main = "Rips Diagram")
# alpha comploex diagram and loop
DiagAlphaCmplx <- alphaComplexDiag(
  X = Xiris, library = c("GUDHI", "Dionysus"), location = TRUE, printProgress = TRUE)
plot(DiagAlphaCmplx[["diagram"]], band = 2 * band[["width"]], main = "Alpha Complex Diagram")
one <- which(DiagAlphaCmplx[["diagram"]][, 1] == 1)
one <- one[which.max(
  DiagAlphaCmplx[["diagram"]][one, 3] - DiagAlphaCmplx[["diagram"]][one, 2])]
plot(Xiris, col = 1, main = "Representative loop")
for (i in seq(along = one)) {
  
  for (j in seq_len(dim(DiagAlphaCmplx[["cycleLocation"]][[one[i]]])[1])) {
    
    lines(DiagAlphaCmplx[["cycleLocation"]][[one[i]]][j, , ], pch = 19,
          cex = 1, col = i + 1)
  }
}
# Persistence Diagrams from Filtration
FltRips <- ripsFiltration(
  X = Xiris, maxdimension = 1, maxscale = 0.5, 
  dist = "euclidean", library = "GUDHI", printProgress = TRUE)
dtmValues <- dtm(X = Xiris, Grid = Xiris, m0 = 0.1)
FltFun <- funFiltration(FUNvalues = dtmValues, cmplx = FltRips[["cmplx"]])
DiagFltFun <- filtrationDiag(
  filtration = FltFun, maxdimension = 1, 
  library = "Dionysus", location = TRUE, printProgress = TRUE)
plot(Xiris, pch = 16, xlab = "",ylab = "")
plot(DiagFltFun[["diagram"]], diagLim = c(0, 1))



