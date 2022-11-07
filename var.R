library(AER)

data("USMacroSW")

y = diff(USMacroSW[, c("unemp", "cpi", "ffrate")])

input = list(y=y, T=NROW(y), K=NCOL(y), H=20)
fit = rstan::stan("var.stan", data=input, chains=2, iter=5000)
res = extract(fit)

getIRF = function(x, colnames, impulse=NULL, response=NULL, horizon=NULL, ci=0.95) {
  
  if(is.null(impulse)) impulse = colnames
  if(is.null(response)) response = colnames
  if(is.null(horizon) || horizon > dim(x)[3]) horizon = dim(x)[3]
  
  array2IRF = function(.array) {
    dimnames(.array)[[1]] = dimnames(.array)[[3]] = colnames
    `[` <- function(...) base::`[`(...,drop=FALSE) # avoid dropping dimension
    tmp = .array[impulse, 1:horizon, response]
    apply(tmp, 1, as.matrix, simplify = F) # convert to list
  }
  
  mid = array2IRF(apply(x, c(2,3,4), median))
  low = array2IRF(apply(x, c(2,3,4), function(.x) quantile(.x, (1-ci)/2)))
  upp = array2IRF(apply(x, c(2,3,4), function(.x) quantile(.x, (1+ci)/2)))
  
  ret = list(irf = mid, Lower = low, Upper = upp, response = response, 
             impulse = impulse, ortho = FALSE, cumulative = FALSE, 
             runs = dim(x)[1], ci = 1 - ci, boot = TRUE, model = "varest",
             method = "Bayesian")
  
  return(structure(ret, class="varirf"))
}

irf = getIRF(res$y_sim, colnames(y), impulse = "ffrate")
par(ask=F)
plot(irf)
