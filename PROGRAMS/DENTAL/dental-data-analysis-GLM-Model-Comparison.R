library(tidyverse);
library(nlme);
library(splines);


setwd("C:/Users/psioda/Documents/GitHub/BIOS-767-Programming/DATA/DENTAL");

dental = read.table("dental-data.txt",header=F,sep=",")
colnames(dental)<-c("id","gender","age8","age10","age12","age14");

## transform data;
dental_vert <- as_tibble(dental) %>% 
  tidyr::pivot_longer(
    cols = starts_with("age"), 
    names_to = "age", 
    values_to = "result", 
    names_prefix = "age")
head(dental_vert)

## convert age to double precision
dental_vert$age   <- as.numeric(dental_vert$age)
dental_vert$age2  <- dental_vert$age^2
dental_vert$age3  <- dental_vert$age^3
dental_vert$age10 <- (dental_vert$age-10)*(dental_vert$age>10)
basis             <- ns(age,df=2)



## fit models;
attach(dental_vert)
lme.lin       = lme(result~gender+age+gender:age                                       ,random=~1|id,method="ML")
lme.quad      = lme(result~gender+age+gender:age+age2+gender:age2                      ,random=~1|id,method="ML")
lme.cub       = lme(result~gender+age+gender:age+age2+gender:age2+age3+gender:age3     ,random=~1|id,method="ML")
lme.linspline = lme(result~gender+age+gender:age+age10+gender:age10                    ,random=~1|id,method="ML")
lme.natspline = lme(result~gender+basis[,1]+gender:basis[,1]+basis[,2]+gender:basis[,2],random=~1|id,method="ML")
detach(dental_vert)

## extract AIC,BIC;
AIC(lme.lin )
AIC(lme.quad)
AIC(lme.cub)
AIC(lme.linspline)
AIC(lme.natspline)

BIC(lme.lin )
BIC(lme.quad)
BIC(lme.cub)
BIC(lme.linspline)
BIC(lme.natspline)

## construct covariate matrices for plots;
t1   <- seq(8,14,by=0.05)
t2   <- t1^2
t3   <- t1^3
tsp  <- (t1-10)*(t1>10)

newt    <- predict(basis,t1)
jvec    <- rep(1,length(newt[,1]))
zerovec <- jvec*0

## estimated means for linear trajectory;
xb.lin    <- cbind(jvec,jvec,t1,t1)
predb.lin <- xb.lin%*%fixed.effects(lme.lin)

xg.lin    <-cbind(jvec,zerovec,t1,zerovec)
predg.lin <-xg.lin%*%fixed.effects(lme.lin)

## estimated means for quadratic trajectory;
xb.quad    <-cbind(jvec,jvec,t1,t2,t1,t2)
predb.quad <-xb.quad%*%fixed.effects(lme.quad)

xg.quad    <-cbind(jvec,zerovec,t1,t2,zerovec,zerovec)
predg.quad <-xg.quad%*%fixed.effects(lme.quad)

## estimated means for cubic trajectory;
xb.cube   <-cbind(jvec,jvec,t1,t2,t3,t1,t2,t3)
predb.cube<-xb.cube%*%fixed.effects(lme.cub)

xg.cube   <-cbind(jvec,zerovec,t1,t2,t3,zerovec,zerovec,zerovec)
predg.cube<-xg.cube%*%fixed.effects(lme.cub)

## estimated means for linear spline;
xb.linspline   <-cbind(jvec,jvec,t1,tsp,t1,tsp)
predb.linspline<-xb.linspline%*%fixed.effects(lme.linspline)

xg.linspline   <-cbind(jvec,zerovec,t1,tsp,zerovec,zerovec)
predg.linspline<-xg.linspline%*%fixed.effects(lme.linspline)

## estimated means for natural cubic spline;
xb.natspline   <-cbind(jvec,jvec,newt[,1],newt[,2],newt[,1],newt[,2])
predb.natspline<-xb.natspline%*%fixed.effects(lme.natspline)

xg.natspline   <-cbind(jvec,zerovec,newt[,1],newt[,2],zerovec,zerovec)
predg.natspline<-xg.natspline%*%fixed.effects(lme.natspline)

## construct plot (polynomial);
plot(t1,predb.natspline,xlab="Time",ylab="Mean Distance",type="n", ylim=c(21,28),main="Polynomial Fits")
lines(t1,predb.lin,col=1,lwd=2)
lines(t1,predg.lin,col=1,lwd=2,lty=2)
lines(t1,predb.quad,col=2,lwd=2)
lines(t1,predg.quad,col=2,lwd=2,lty=2)
lines(t1,predb.cube,col=3,lwd=2)
lines(t1,predg.cube,col=3,lwd=2,lty=2)
legend(8,28,c("Linear","Quadratic","Cubic"),col=1:3,lty=1)

## construct plot (splines);
plot(t1,predb.natspline,xlab="Time",ylab="Mean Distance",type="n",ylim=c(21,28),main="Spline Fits")
lines(t1,predb.linspline,col=4,lwd=2)
lines(t1,predg.linspline,col=4,lwd=2,lty=2)
lines(t1,predb.natspline,col=5,lwd=2)
lines(t1,predg.natspline,col=5,lwd=2,lty=2)
lines(t1,predb.cube,col=3,lwd=2)
lines(t1,predg.cube,col=3,lwd=2,lty=2)
legend(8,28,c("Linear Spline","Natrual Cubic Spline","Cubic Polynomial"),col=c(4,5,3),lty=1)


