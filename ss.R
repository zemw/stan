library(rstan)
library(AER)

data("USMacroSW")
gdp = 400*diff(log(USMacroSW[,'gdpjp']))

fit = stan("ss.stan", data = list(y = gdp, T = NROW(gdp)))
res = extract(fit)

plot(unclass(gdp), type="l")
lines(colMeans(res$z), col="red")

plot(colMeans(res$z))
