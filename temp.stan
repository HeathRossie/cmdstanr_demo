data{
  int N;
  real y[N];
}

parameters{
  real mu;
  real<lower=0> sig;
}

model{
  y ~ normal(mu, sig);
}
