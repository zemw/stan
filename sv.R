library(AER)
data("USMacroSW")
y = window(diff(USMacroSW[, 'gbpusd']), start=1970)

fit = rstan::stan("sv.stan", data=list(T=length(y), y=y), chains = 2, iter = 5000)
print(fit, pars = c("mu", "phi", "sigma"))

res = extract(fit)
h = colMeans(res$h)
plot(h, type="l")
