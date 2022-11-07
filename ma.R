
y = arima.sim(list(ma=c(0.5, 0.7)), 200)

input = list(
  y = y,
  T = 200, 
  Q = 2
)
fit = rstan::stan("ma.stan", data=input, chains=2, iter=10000)
print(fit, pars = c("mu", "theta", "sigma"))
