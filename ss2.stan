// --------------------------------------------------------------
// State Space Model (Local-level with AR noise)
//
//   y[t] = z[t]   + c[t]
//   z[t] = z[t-1] + v[t], v[t] ~ N(0, sigma_v)
//
//   c[t] = Σ phi(k)*c[t-k] + u[t], u[t] ~ N(0, sigma_u)
// --------------------------------------------------------------

data {
    int T;
    vector[T] y;
    // int L; # number of lags in AR error component
}

parameters {
    vector[T] z;
    real phi; // AR(1) coefficient
    // vector[L] phi;
    real<lower=0> sigma_u;
    real<lower=0> sigma_v;
    // real<lower=0> sigma_3;
}
transformed parameters {
  vector[T] c;
  c = y - z;
}

model {
  
  for (t in 2:T) {
    y[t] ~ normal(z[t] + phi*c[t-1], sigma_u);
  }

  for (t in 2:T) {
      z[t] ~ normal(z[t-1], sigma_v);
  }

  // priors on initial values
	z[1] ~ normal(y[1], sigma_v);

  // hyperparameters
	sigma_u ~ inv_gamma(0.001, 0.001);
	sigma_v ~ inv_gamma(0.001, 0.001);

}
