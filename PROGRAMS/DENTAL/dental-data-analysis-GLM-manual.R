library(tidyverse);

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
dental_vert$age <-
  as.numeric(dental_vert$age)
head(dental_vert)

x1 = (dental_vert$gender=="F");
x2 = (dental_vert$gender=="F")*dental_vert$age;
x3 = (dental_vert$gender=="M");
x4 = (dental_vert$gender=="M")*dental_vert$age;
x <- cbind(x1,x2,x3,x4);
y <- dental_vert$result;

M = 27;
n = 4;
convCrit = 1e-12;
maxIter  = 100;

## initialize the estimate of beta 
betaHat = solve(t(x)%*%x)%*%t(x)%*%y;

## iterative ML algorithm; 
change    = 1000;
iteration = 0;

    repeat
    {
        ## Accumulate outer products of residuals based on current betaHat 
        ## to construct estimate of sigmaHat
        sigmaHat = matrix(0,nrow=n,ncol=n);
        for (i in 1:M)
        {  
          rows     = which(dental_vert$id==i)
          xr       = x[rows,];
          yr       = y[rows];
          sigmaHat = sigmaHat + (yr-xr%*%betaHat)%*%t(yr-xr%*%betaHat);
        }
        sigmaHat = 1/M*sigmaHat;
    
        ## Update weight matrix 
        W = solve(sigmaHat);
    
        ## Update estimate of betaHat
        t1 = 0;
        t2 = 0;
        for (i in 1:M)
        { 
          rows     = which(dental_vert$id==i)
          xr       = x[rows,];
          yr       = y[rows];
          t1 = t1 + t(xr)%*%W%*%xr;
          t2 = t2 + t(xr)%*%W%*%yr;
        }
        
        ## store prior value of betaHat
        betaHatPrev = betaHat;
        
        ## update betaHat;
        betaHat     = solve(t1)%*%t2;
    
        ## compute change in betaHat 
        change      = sum(abs(betaHat-betaHatPrev));
    
        ## increment iteration counter
        iteration   = iteration + 1;
        
        ## check termination conditions;
        if (iteration == maxIter) {break;}
        if (change < convCrit) {break;}
    }   

    stdError = sqrt(diag(solve(t1)));
    z        = betaHat/stdError;
    pv       = pnorm(-abs(z))*2;
    
    finalResults = cbind(betaHat,stdError,z,pv);
    colnames(finalResults) <- c("Estimate", "StdError", "z", "P-value");
    
    print(round(finalResults,4));
    
    print(round(sigmaHat,4));
