library(rstan)

mu = cumsum(rnorm(300, .1, .1))
ar = arima.sim(list(ar=.5), n=300)
y = mu + ar
plot(y, type="l")

fit = stan("ss2.stan", data=list(T=300, y = y), chains=2, iter=5000)
print(fit, pars=c("phi", "sigma_u", "sigma_v"))
# sigma_v is not estimated accurately

res = extract(fit)
lines(colMeans(res$z), col="red")
