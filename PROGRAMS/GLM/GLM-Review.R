cell <- matrix(
  c(11, 0, 0,
    18, 0, 4,
    20, 0, 20,
    39, 0, 100,
    22, 1, 0,
    38, 1, 4,
    52, 1, 20,
    69, 1, 100,
    31, 10, 0,
    68, 10, 4,
    69, 10, 20,
    128, 10, 100,
    102, 100, 0,
    171, 100, 4,
    180, 100, 20,
    193, 100, 100),ncol=3,byrow=T)
cell = data.frame(cell);
colnames(cell)<-c("nDiff","TNF","INF")

cell.fit <- glm(nDiff ~ TNF + INF + TNF:INF,family=poisson,data=cell)
summary(cell.fit)




### Analysis of Deviance;
cell.fit.full <- glm(nDiff ~ TNF + INF + TNF:INF,family=poisson,data=cell)
cell.fit.redu <- glm(nDiff ~ TNF + INF,          family=poisson,data=cell)
lrt           <- cell.fit.redu$deviance - cell.fit.full$deviance
pv            <- pchisq(lrt,df=1,lower.tail=F)
print(round(c(cell.fit.full$deviance,cell.fit.redu$deviance,lrt,pv),5))



## Model Selection
setwd("C://Users//psioda//Documents//GitHub//BIOS-767-Programming//DATA//GLM")
simDat <- read.csv(file="simDat.dat",head=F);
colnames(simDat) <- c("s", "y", paste("x",1:30,sep="") )
simDat<-simDat[,-1]

require(Rcmdr);
fit.full <- glm(y ~ .,family=binomial,data=simDat) 
stepwise(fit.full, direction="forward/backward",criterion="AIC")
stepwise(fit.full, direction="backward",criterion="AIC")



## Data simulation
set.seed(11321);

n   = 100;
z   = runif(n);
x   = cbind(rep(1,n),z);
beta= c(-3,5);
pi  = exp(x%*%beta)/ (1+exp(x%*%beta))
y   = rbinom(n,1,pi)

glm(y ~ 1+z,family=binomial(link = "logit"))
glm(y ~ 1+z,family=binomial(link = "probit"))
glm(y ~ 1+z,family=binomial(link = "cloglog"))



