data(iris)

input = list(
  x = iris$Petal.Length,
  y = iris$Petal.Width,
  N = NROW(iris)
)

fit = rstan::stan("lm.stan", data=input, chains=1, iter=2000)
print(fit)
