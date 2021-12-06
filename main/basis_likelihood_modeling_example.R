###############################################################################
# Basic Likelihood Modeling Example 
###############################################################################

library(data.table)

# Simulation Setting 

beta <- as.matrix(c(1,10),nrow=2,ncol=1) # b0,b1,b2,b3,b4

sigma_2 <- 25 # s^2

X <- as.matrix(cbind(1,rnorm(1000,0,1)))

y <- X %*% beta + rnorm(1000,0,sqrt(sigma_2))


###############################################################################

# likelihood function 

log_lik <- function(theta,y,x){
  
  n <- nrow(X) # data size 
  k <- ncol(X) # parameter
  beta <- theta[1:k] # beta 
  sigma_2 <- theta[k+1]
  e <- y-X%*%beta 
  lik <- -.5*n*log(2*pi)-.5*n*log(sigma_2) - (t(e)%*%e)/(2*sigma_2)

  return(-lik)
  
}


mle <- optim(fn=log_lik,
             par=c(1,1,1),
             hessian=TRUE,
             lower = -Inf,
             upper = Inf,
             control = list(maxit=3000),
             y=y,
             x=X)

mle$par
sqrt(diag(solve(mle$hessian)))

fit<- lm(y~X[,-1])
summary(fit)


sqrt(solve(mle$hessian)) # Fihser Information Inverse 


######################################################################### 

# 질문 X의 dimension을 늘렸을 때 Beta값이 이상하게 추정되는 이유는 뭐지? 





