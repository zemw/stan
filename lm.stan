data {
  int<lower=0> N;
  vector[N] x;
  vector[N] y;
}
parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}
model {
  y ~ normal(alpha + beta * x, sigma);
  
  // priors
  alpha ~ std_normal();
  beta ~ std_normal();
  sigma ~ inv_gamma(0.001,0.001);
  
  // If no prior were specified in the model block, the constraints on theta
  // ensure it falls between 0 and 1, providing theta an implicit uniform prior.
  // For parameters with no prior specified and unbounded support, the result is
  // an improper prior. Stan accepts improper priors, but posteriors must be
  // proper in order for sampling to succeed.
}
