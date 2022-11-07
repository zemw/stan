// --------------------------------------------------------------
// State Space Model (Local-level model, random walk plus noise)
//
//   y_t = z_t + u_t    , u_t ~ N(0, sigma_1)
//   z_t = z_{t-1} + v_t, v_t ~ N(0, sigma_2)
// --------------------------------------------------------------

data {
    int<lower=1> T;
    vector[T] y;
}
parameters {
    vector[T] z;
    real<lower=0> sigma_1;
    real<lower=0> sigma_2; // controls smoothness of the trend
}
model {
    for (t in 1:T) {
        y[t] ~ normal(z[t], sigma_1);
    }

    for (t in 2:T) {
        z[t] ~ normal(z[t-1], sigma_2);
    }
    
    sigma_1 ~ cauchy(5, 5);
    sigma_2 ~ cauchy(1, 1);
}
