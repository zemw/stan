data {
  int<lower=0> T;  // number of observations
  int<lower=1> K;  // number of variables
  int<lower=1> H;  // forecast horizon
  matrix[T,K] y;
}
parameters {
  matrix[K, K] beta;
  // cov_matrix[K] Sigma;
  
  // model the covariance matrix in LKJ-correlation 
  // gives you more control over scales and correlations
  corr_matrix[K] Omega;   // correlation
  vector<lower=0>[K] tau; // scale
}
transformed parameters {
  cov_matrix[K] Sigma = quad_form_diag(Omega, tau);
}
model {
  // priors
  tau ~ cauchy(0, 2.5);
  Omega ~ lkj_corr(1);

  for (t in 2:T) {
    y[t] ~ multi_normal(beta*y[t-1]', Sigma);
  }

}
generated quantities {
  // generate IRFs
  vector[K] y_sim[K,H];
  for (k in 1:K) {
    vector[K] shock = rep_vector(0,K); shock[k] = 1;
    // apply cholesky identification
    y_sim[k][1] = cholesky_decompose(Sigma)*shock;
    for (h in 2:H) {
      y_sim[k][h] = beta*y_sim[k][h-1];
    }
  }
}
