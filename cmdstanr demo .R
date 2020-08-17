# cmdstanrのdemoコード
# 参考；https://mc-stan.org/cmdstanr/reference/model-method-sample.html

# これでいんすとーるする
# devtools::install_github("stan-dev/cmdstanr")

library(cmdstanr)

# これは一回やっとけばok
# install_cmdstan()

# これは魔法だと思って実行してる
set_cmdstan_path()

# ここからcmdstanrのデモ
start = Sys.time()
mod = cmdstan_model("/Users/matsuihiroshi/Desktop/temp.stan") ##モデルのコンパイル
mid = Sys.time()
fit = mod$sample(
  data=list(N=100, y=rnorm(100)),
  seed = 123,
  chains = 4,
  iter_sampling = 100000,
  iter_warmup = 50000,
  parallel_chains = 4
)
# 注意
# rstanと引数の名前が違うのがある
# rstanのiterと違って、iter_samplingは「warmup後何個サンプリングするか」
# なので、後でdraws()したときに「あれ！？warmupの部分きりとられてないじゃん！」
# とならないように

end = Sys.time()
end - mid 


# 得られたサンプルを触ってみる
# https://github.com/stan-dev/posterior

# install.packages("posterior", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
library(posterior)
library(tidyverse)

samples = fit$draws()
str(samples)
res = as_draws_df(samples)

ggplot(res) + 
  geom_histogram(aes(x=res$mu))

mean(res$mu)
quantile(res$mu, c(.025, .975))

# bayesplot使って事後分布見てみる
library(bayesplot)
mcmc_trace(fit$draws("mu"))
mcmc_hist(fit$draws("mu"))
mcmc_hist(fit$draws("sig"))


# 最尤推定もできる
res.mle = mod$optimize(data = list(N=100, y=rnorm(100)), seed = 123)
res.mle$draws()


# 変分ベイズもできる
fit_vb = mod$variational(data = list(N=100, y=rnorm(100)), seed = 123, output_samples = 4000)
fit_vb$draws()


# ここからふつーにrstanで同じことやって速度比較するコード
library(rstan)
start = Sys.time()
mod = stan_model("/Users/matsuihiroshi/Desktop/temp.stan")
mid = Sys.time()
rstan_options(auto_write=TRUE)
options(mc.cores = parallel::detectCores())
fit = sampling(mod, data=list(N=100, y=rnorm(100)),
               chain = 4, iter = 100000, warmup = 100000/2)
end = Sys.time()

end - start
end - mid

# 備考
# コンパイルは7倍くらい
# サンプリングはだいたい2倍くらい
# cmdstanの方がはやかった
