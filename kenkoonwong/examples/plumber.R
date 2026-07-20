# plumber.R

#* Generate a scatter plot
#* @serializer png
#* @get /plot
function() {
mat <- cbind(Uni05 = (1:100)/21, Norm = rnorm(100),
             `5T` = rt(100, df = 5), Gam2 = rgamma(100, shape = 2))
boxplot(mat) # directly, calling boxplot.matrix()
}



