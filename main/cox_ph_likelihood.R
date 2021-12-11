###############################################################################
# Multivariate cox ph likelihood modeling  
###############################################################################


# glm 처럼 formula 입력하고 data 넣으면 output이 나오게 
# beta 


# Required packages
# ordering 

library(survival)
library(knitr)
library(Matrix)
library(stringr)


# Cox ph 
# h(t) = p(t) / p(T > t)
# log(P(T > t)) = - integral(0,t) h(s) ds 
# log(p(t)) = log(h(t)) - log(P(T>t))

########################################################################################################3
# Log partial likelihood for the Cox proportional hazards model
########################################################################################################

# X      : design matrix
# status : vital status (1 - dead, 0 - alive, censored)
# times  : survival times
# n.obs  : number of observed events
########################################################################################################

# Step1 : surv 형태로 함수 하나 만들기..? 

surv <- function(time,event,data){

  cat(ifelse(event==0,paste0(time,'+'),time))
  o <- order(time)
  return(o)
  
}


########################################################################################################


# Step2 : formula를 받아서 cox_ph output과 같게 만들기.. 

cox_ph <- function(formula,data){
  

  # extract formula   
  form <- as.character(formula)
  
  st <- regexpr('[(]',form[2])[1]
  mid <- regexpr('[,]',form[2])[1]
  dt <- regexpr('[)]',form[2])[1]
  
  
  
  # time variable 
  times <- data[,gsub(" ","",substr(form[2],st+1,mid-1))]
  # times <- times[order(times)]
  
  # event variable 
  event  <- data[,gsub(" ","",substr(form[2],mid+1,dt-1))]
  # event <- event[order(times)]
  
  # X matrix ordered by times asc 
  
  X <- model.matrix(formula(paste0('~',form[3])),data)[,-1]
  
  # := risk set 
  
  risk.set <- function(t) which(times >= t)
  
  rs <- apply(as.matrix(times[as.logical(event)]), 1, risk.set)
  
  log_lik <- function(beta) {
    
    XB <- X%*%beta 
    status <- as.logical(event) # event = 1 
    n.obs <-sum(status)
    lpl1 <- sum(XB[status])
    temp <- c() 
    for(i in 1:n.obs){
      temp[i] <- temp[i] <- log(sum(exp(XB[rs[[i]]])))
    }
    
    lpl2 <- sum(temp)
    
    return(-lpl1+lpl2)
  }
  
  # Fisher Scoring Algorithm 
  
  
  return(optim(c(rep(0,dim(X)[2])),log_lik, control = list(maxit = 1000)))
    
}
  
  

cox_ph(surv(futime,fustat) ~ age+resid.ds,data=ovarian)
coxph(Surv(futime,fustat) ~ age+resid.ds,data=ovarian[order(ovarian$futime),])
  

########################################################################################################





