#Trying to figure out my update fitness error
x <- seq(-10, 10, by = .1)
normal = dnorm(x, 0, 0.5)
plot(normal)
plot(x, normal)
normal = dnorm(x, 0.3, 0.5)
plot(x, normal)
pnorm(-1, mean=0, sd=0.5, lower.tail=TRUE)
#0.02275013
pnorm(-1, mean=0, sd=0.4, lower.tail=TRUE)
#0.006209665
pnorm(-1, mean=0, sd=0.3, lower.tail=TRUE)
#0.0004290603
