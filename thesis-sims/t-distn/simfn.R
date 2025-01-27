library(gmvjoint)
ff <- function(df, ...){ 
  dat <- simData(dof = df, D = diag(c(0.25, 0.05)), beta = c(2, 0.33, -0.5, 0.25),
                 theta = c(-2.9, 0.1), zeta = c(0, -0.2),
                 gamma = 0.5, family = list('gaussian'),
                 return.ranefs = F)
  dd <- dat$data
  fit <- joint(list(Y.1 ~ time + cont + bin + (1 + time|id)),
               Surv(survtime, status) ~ bin, data = dd,
               family = list('gaussian'),
               ...)
  fit
}

test <- ff(3, control = list(verbose = T, tol.rel = 1e-3))
summary(test$fit)

library(cli)

dfs <- c(2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 25, 30)
N <- 100

fit.df <- function(df, ...){
  nm <- paste0("Simulation study, df = ", df)
  fn <- paste0('./fits/df_', df, '.RData') # the file name
  cli_progress_bar(name = nm, total = N)
  fits <- vector("list", N)
  for(i in 1:N){
    this <- tryCatch(suppressMessages(ff(df, control = list(tol.rel = 1e-3, maxit = 100, return.dmats = FALSE))),
                     error = function(e) NULL)
    if(is.null(this)){
      fits[[i]] <- NULL
    }else{
      fits[[i]] <- this$fit
    }
    cli_progress_update()
  }
  cli_progress_done()
  cli_alert_success(sprintf("\nSaving in %s\n", fn))
  out <- list(fits = fits)
  save(out, file = fn)
}

for(d in dfs) fit.df(d)
