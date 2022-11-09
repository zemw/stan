/*
Dynamic Factor Model (DFM) with single factor

 Y[t,p] = Gamma[p] * x[t] + e, e ~ N(0,1)
 x[t] = theta * x[t-1] + w, w ~ N(0, sigma)
 
*/

data {
  int T; // number of obs
  int P; // number of observed variables
  int frequency[P];
  matrix[T,P] Y; //dataset of generated series
}

parameters {
  vector[T] xhat; // state variable
  real<lower = 0> gamma_1; // First factor loading--restricted to positive for identificaton
  vector<lower = 0>[P-1] gamma_rest; // The rest of the factor loadings
  vector[1] theta; // AR(1) Coef on state series
  real<lower = 0> sigma_state; // The scale of innovations to the state
}

transformed parameters {
  vector[P] gamma; // complete factor loading vector
  gamma[1] = gamma_1;
  gamma[2:P] = gamma_rest;
}

model {
  // priors
  xhat[1] ~ normal(0,1);
  sigma_state ~ normal(0, .3); 
  gamma ~ normal(0, 1);
  theta ~ normal(0, 1);

  // State Equation
  for(t in 2:T) {
    xhat[t] ~ normal(xhat[t-1]*theta[1], sigma_state);
  }

  // Measurement Equations
  for(t in 1:T) {
    for(p in 1:P) {
      # skip missing observations
      if(Y[t,p] != -999) {
        if (frequency[p] == 1) {
          # monthly observation
          Y[t,p] ~ normal(xhat[t]*gamma[p], 1);
        } else if (frequency[p] == 3 && t >2) {
          # quarterly observation
          Y[t,p] ~ normal(1/3*(xhat[t] + xhat[t-1] + xhat[t-2])*gamma[p], 1);
        }
      } // end of if statement 
    }
  }
}
