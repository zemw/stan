library(rstan)

# preparing data: New York Fed Nowcasting data sample
fed = nowcasting::NYFED
data = nowcasting::Bpanel(fed$base, fed$legend$Transformation, 
                          NA.replace = F, na.prop = 1, h = 0)
data = scale(data) # normalize to mean=0 and sd=1

# replace NA, stan does not accept NA
data_tmp = tidyr::replace_na(data, -999)
freq = ifelse(fed$legend$Frequency==12, 1, 3)

# estimate the model
dfm_model <- rstan::stan(
  file = "dfm.stan",
  data = list(
    T = nrow(data_tmp),
    P = ncol(data_tmp),
    frequency = freq,
    Y = data_tmp
  ),
  chains = 4,
  iter = 2000,
  cores = 4
)

# extract quantile from parameter samples
extract_prob = function(samples, par, prob = 0.5) {
  # make sure it is the list returned from rstan::extract
  stopifnot(is.list(samples) && !is.null(samples$lp__)) 
  stopifnot(par %in% names(samples))
  x = samples[[par]]
  ndim = length(dim(x))
  if (ndim == 1) {
    quantile(x, probs = prob)
  } else {
    apply(x, 2:ndim, function(.x) quantile(.x, probs = prob))
  }
}

res = rstan::extract(dfm_model)
xhat = extract_prob(res, "xhat")
gamma = extract_prob(res, "gamma")
xhat = ts(xhat, 1985, 2017, 12)

idx = 10
plot(data[,idx])
lines(xhat * gamma[idx], col="red")
title(fed$legend$SeriesName[idx])
