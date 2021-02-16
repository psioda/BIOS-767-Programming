library(Matrix);
library(magic);

#  u <- model object from fit

robust.cov <- function(u){
  form <-  formula(u)
  mf <- model.frame(form,getData(u))
  Xmat <- model.matrix(form,mf)
  ids <- unique(u$groups)
  m <- length(ids)
  Vlist <-  as.list(ids)
  for (i in 1:m){
    Vlist[[i]] <- getVarCov(u,individual=ids[i],type="marginal")
  }
  V <- Reduce(adiag,Vlist)
  Vinv <- solve(V)
  Sig.model <- solve(t(Xmat)%*%Vinv%*%Xmat)
  resid <- diag(residuals(u,type="response"))
  ones.list <- lapply(Vlist,FUN=function(u){matrix(1,nrow(u),ncol(u))})
  Ones <- Reduce(adiag,ones.list)
  meat <- t(Xmat)%*%Vinv%*%resid%*%Ones%*%resid%*%Vinv%*%Xmat
  Sig.robust <- Sig.model%*%meat%*%Sig.model
  se.robust <- sqrt(diag(Sig.robust))
  se.model <- sqrt(diag(Sig.model))
  return(list(Sig.model=Sig.model,se.model=se.model,Sig.robust=Sig.robust,se.robust=se.robust))
}

