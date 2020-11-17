## Replicates results in Zucco et al 2019 in Research and Politics
## Requires the following data files:
## 1) data-bls.RData
## 2) data-abcp.RData
## 3) tab-ministries-translations.csv
## 4) data-objective.RData
## Instructions:
## Save all datafiles to the same local folder 
## Change path in first line of code
## Install package BradleyTerry2: install.packages("BradleyTerry2")
## You might also need to download and install package "qvcalc" from github

setwd("~/Dropbox/Data/Paper-CabinetValues/Replic")
rm(list=ls(all=TRUE))
library(BradleyTerry2)#install.packages("BradleyTerry2")
library(xtable)#install.packages("xtable") for LaTeX table output

############################################################
## BT with the BLS data      							  ##
############################################################

#Load the pre-prepared data from BLS and estimate
load("data-bls.RData")
the.bls <- the.set
the.bls$the.set$ref <- factor(gsub("X","Y",the.bls$the.set$ref))
the.bls$resp$V <- factor(gsub("X","Y",the.bls$resp$V))
BTbls <- BTm(cbind(winX1, winX2), X1, X2, data = the.bls, br = TRUE)
summary(BTbls) #In the basic model, estimates = abilities

# total number of respondents
length(unique(the.bls$the.set$ref))

# total number of comparisons
dim(the.bls$the.set)

#Using refcat to set one ministry to 0
#This is the part that might require  the qvcalc from Github
#Without qvcalc results are the same, but can't set refcat
max.M <- names(which.max(BTabilities(BTbls)[,"ability"]))
BTbls <- update(BTbls, refcat = max.M)
BTabilities(BTbls)

# FUse "summary" to get the significance of tests relative to baseline
valbt <- round(data.frame(summary(BTbls)$coef),5)
valbt$sig <- ifelse(valbt[,4]<0.1&valbt[,4]>=0.05,".",
				ifelse(valbt[,4]<0.05&valbt[,4]>=0.01,"*",
				ifelse(valbt[,4]<0.01,"**","")))
valbt$Code <- as.numeric(gsub("\\.\\.M","", rownames(valbt)))				
stars <- subset(valbt,select=c(Code,sig))				
valbt <- round(data.frame(BTabilities(BTbls)),5)
valbt$Code <- as.numeric(gsub("M","", rownames(valbt)))
valbt <- merge(valbt,stars,by="Code",all.x=T)
valbto  <- merge(valbt ,the.bls$cabnames,by="Code",all.x=T)

# Read in the English names to ministries, and merge with results
eng <- read.csv("tab-ministries-translations.csv")
eng <- subset(eng,select=c("Code","eng"))
valbto <- merge(valbto,eng,by=c("Code"))

#Do a boostrapped "rank" analysis to compute rank confidence intervals ###
#First, simulate 1000 (can't simulate the first ministry)
library(mvtnorm )
set.seed(1977)
sims <- rmvnorm(1000, mean = coef(BTbls), sigma = vcov(BTbls))
	ranks <- apply(sims ,1,function(x){37-rank(x)})
	ranks.ci <- round(apply(ranks,1,quantile,probs=c(0.05,0.5,0.95)))
	ranks.tab <- t(ranks.ci[,sort(ranks.ci[2,],index.return=2)$ix])
	rownames(ranks.tab)	 <- gsub("\\.\\.","",rownames(ranks.tab)	)			
	#Can't simulate first, but can test it against others 
	rankh <- sum(summary(BTbls)$coef[,'Pr(>|z|)']>0.05)#maximum rank for M17
	ranks.tab[,2] <- ranks.tab[,2]+1
	ranks.tab[,3] <-  ifelse(ranks.tab[,3]<=rankh
				,ranks.tab[,3]
				,ranks.tab[,3]+1)#add one to those ouside of M17 range
	ranks.tab <- data.frame(rbind(highest=c(1,1,rankh),ranks.tab))
	rownames(ranks.tab)[1] <- max.M
	names(ranks.tab) <- c("rank.05","rank.med","rank.95")
	ranks.tab$Code <- as.numeric(gsub("M","",rownames(ranks.tab))	)

#Store estimates for later use#
valbto$pasta <- valbto$eng #use English
valbto <- subset(valbto,select=c(Code,ability,s.e.,sig,Level,pasta))
valbto <- merge(valbto,ranks.tab,by="Code")
valbto <- valbto[order(valbto$ability,decreasing=T),] #ordered
valbto$ci.width <- valbto$rank.95-valbto$rank.05
save(valbto,file="out-BLScabestimates-BT.RData")
write.csv(valbto,file="out-BLScabestimates-BT.csv",row.names=F)

the.bls.table <- valbto

############################################################
## BT with the ABCP data      							  ##
############################################################
load("data-abcp.RData")
BT <- BTm(cbind(winX1, winX2), X1, X2, data = the.set,br = TRUE)
max.M <- names(which.max(BTabilities(BT)[,"ability"]))
BT  <- update(BT , refcat = max.M)


valbt <- round(data.frame(summary(update(BT , refcat = "M03"))$coef),5)
valbt$sig <- ifelse(valbt[,4]<0.1&valbt[,4]>=0.05,".",
				ifelse(valbt[,4]<0.05&valbt[,4]>=0.01,"*",
				ifelse(valbt[,4]<0.01,"**","")))
valbt$Code <-  as.numeric(gsub("\\.\\.M","", rownames(valbt)))
stars <- subset(valbt,select=c(Code,sig))
valbt <- round(data.frame(BTabilities(BT)),5)#preferable because includes baseline
valbt$Code <- as.numeric(gsub("M","", rownames(valbt)))
valbt <- merge(valbt,stars,by="Code",all.x=T)
valbto <- valbto[order(valbto$ability,decreasing=T),] #ordered
valbto  <- merge(valbt ,the.set$cabnames,by="Code",all.x=T)
valbto <- subset(valbto,select=c(Code,ability,s.e.,sig,Level,pasta))

# Read in the English ministry namesnames proposed and merge
eng <- read.csv("tab-ministries-translations.csv")
eng <- subset(eng,select=c("Code","eng"))
valbto <- merge(valbto,eng,by=c("Code"))

# Compute bootstrapped ranks
library(mvtnorm )
set.seed(1977)
BT  <-update(BT , refcat = max.M)
sims <- rmvnorm(1000, mean = coef(BT), sigma = vcov(BT))
	ranks <- apply(sims ,1,function(x){37-rank(x)})
	ranks.ci <- round(apply(ranks,1,quantile,probs=c(0.05,0.5,0.95)))
	ranks.tab <- t(ranks.ci[,sort(ranks.ci[2,],index.return=2)$ix])
	rownames(ranks.tab)	 <- gsub("\\.\\.","",rownames(ranks.tab)	)			
	#Can't simulate first, but can test it against others 
	rankh <- sum(summary(BT)$coef[,'Pr(>|z|)']>0.05)
	ranks.tab[,2] <- ranks.tab[,2]+1
	ranks.tab[,3] <-  ifelse(ranks.tab[,3]<=rankh
				,ranks.tab[,3]
				,ranks.tab[,3]+1)#add one to those ouside of M03 range
	ranks.tab <- data.frame(rbind(highest=c(1,1,rankh),ranks.tab))
	rownames(ranks.tab)[1] <- max.M
	names(ranks.tab) <- c("rank.05","rank.med","rank.95")
	ranks.tab$Code <- as.numeric(gsub("M","",rownames(ranks.tab))	)

# Keep only the estimates, don't need auxiliary data #
valbto$pasta <- valbto$eng #use English
valbto <- subset(valbto,select=c(Code,ability,s.e.,sig,Level,pasta))
valbto <- merge(valbto,ranks.tab,by="Code")
valbto <- valbto[order(valbto$ability,decreasing=T),]
valbto$ci.width <- valbto$rank.95-valbto$rank.05
write.csv(valbto,file="out-ABCPcabestimates-BT.csv",row.names=F)
save(valbto,file="out-ABCPcabestimates-BT.RData")

the.abcp.table <- valbto

############################################################
## TABLE 1 THE R&P PAPER			  			  		  ##
############################################################

combined.table <- merge(the.bls.table
			,the.abcp.table
			,by=c("Level","pasta")
			,suffixes=c("",".abcp"))
combined.table <- combined.table[,-grep("Code",names(combined.table))]
combined.table <- combined.table[,-grep("rank.med",names(combined.table))]
combined.table <- combined.table[,-grep("ci.width",names(combined.table))]
combined.table <- combined.table[order(combined.table$ability,decreasing=T),]
x.combined.table <- xtable(combined.table,digits=c(0,0,0,2,2,0,0,0,2,2,0,0,0))
caption(x.combined.table) <- "Estimated Worth of Ministries --- Expert and Elite Surveys"
label(x.combined.table) <- "tab-combined"
align(x.combined.table) <- "lllrlrllrlrl"
print(x.combined.table,include.rownames=F,caption.placement="top")

#Save the .csv version (using the English ministry names)
combined.table$ability <- round(combined.table$ability,2)
combined.table$ability.abcp <- round(combined.table$ability.abcp,2)
write.csv(combined.table
	,file="tab-combinedtable.csv"
	,row.names=F)


############################################################
## COMPARING THE TWO SETS OF ESTIMATES					  ##
############################################################

rm(list=ls(all=TRUE))
abcp <- read.csv("out-ABCPcabestimates-BT.csv")
abcp$rank <- 1:nrow(abcp)
bls <- read.csv("out-BLScabestimates-BT.csv")
bls$rank <- 1:nrow(bls)
d <- merge(abcp,bls
		,by=c("Code","Level","pasta")
		,suffixes=c(".abcp",".bls"))
rownames(d) <-paste("M",sprintf("%02.0f", d$Code),sep="")

# Width of rank CI (mentioned in the paper)
range(d$ci.width.bls)
median(d$ci.width.bls)
range(d$ci.width.abcp)
median(d$ci.width.abcp)
d$noise <-   d$rank.abcp-d$rank.bls

#Measures of association (mentioned in the paper)
cor.test(d$ability.abcp,d$ability.bls)
cor.test(d$rank.abcp,d$rank.bls,method="spearman")
cor.test(d$rank.05.abcp,d$rank.05.bls,method="spearman")
cor.test(d$rank.95.abcp,d$rank.95.bls,method="spearman")

# Test overlap between within rank CI
# as in "The rank confidence intervals in the two sets of estimates overlap for all portfolios save two.
my.overlap <- function(x){intersect(x[1]:x[2],x[3]:x[4])}
x<-subset(d,select=c(rank.05.bls,rank.95.bls,rank.05.abcp,rank.95.abcp))
the.overlap <- apply(x,1,my.overlap)
d$rank.overlap <-  sapply(the.overlap,length)
subset(d,rank.overlap==0)

# Figure 1, in the paper #
jpeg(file="fig-compareBLS-ABCP-labels.jpg"
	,res=400,width=8,height=8,units="in")
par(mar=c(5,5,1,1))
plot(d$ability.bls,d$ability.abcp,bty="n"
	,type="n",cex=.8
	,xlab="Worth of Portfolio According to Elites"
	,ylab="Worth of Portfolio According to Experts")		
polygon(x=c(-1.8,1,1,-1.8),
		y=c(-.55,-.55,1,1),border=NA,col=gray(0.8))
polygon(x=c(-3.1,-2,-2,-3.1),
		y=c(-1.65,-1.65,-.65,-.65),border=NA,col=gray(0.8))
polygon(x=c(-4.1,-3.1,-3.1,-4.1),
		y=c(-2.5,-2.5,-1.7,-1.7),border=NA,col=gray(0.8))
polygon(x=c(-5.8,-4.3,-4.3,-5.8),
		y=c(-4.3,-4.3,-2.45,-2.45),border=NA,col=gray(0.8))		
reg <- lm(ability.abcp~ ability.bls, data=d)
outliers <-  d$rank.overlap==0 
noisy <- abs(d$noise)>=10
points(d$ability.bls,d$ability.abcp
	,pch=ifelse(outliers|noisy,21,19)
	,cex=.8 )
abline(reg=reg)
text(d$ability.bls,d$ability.abcp,
	,labels=ifelse(outliers|noisy,as.character(iconv(as.character(d$pasta))),NA)
	,cex=0.8
	,pos=4)
dev.off()

############################################################
## PLOT TO REPLACE COMBINED TABLE						  ##
## Not actually used in paper 							  ##
############################################################
the.lab <- gsub(" $","",gsub("\\(.*\\)","",d$pasta))
png(file="fig-blsestimates+rankci.png",width=12,height=6,units="in",res=300)
par(mar=c(9.5,3.5,0.5,0.5))
n <- nrow(d)
d <- d[order(d$ability.bls,decreasing =T),]
plot(1:n,d$ability.bls,bty="n",ylim=c(-5.5,0.5),xaxt="n",ylab="",xlab="",cex=0.7)
#abline(h=c(0,d$ability.bls[n]),lty=2)
#segments(x0=1:n,x1=1:n,
#		y0=d$ability.bls-1.64*d$s.e..bls,
#		y1=d$ability.bls+1.64*d$s.e..bls)
abline(v=1:n,lty=3,col=gray(0.7))
segments(x0=1:n,x1=1:n,
		y0=d$ability.bls[d$rank.05.bls],
		y1=d$ability.bls[d$rank.95.bls])
points(1:n,d$ability.bls,bg="white",pch=21,cex=0.7)
axis(side=1,at=1:n,the.lab,las=2,cex.axis=0.7)
mtext(side=2,line=2.5,"Estimated Worth")
dev.off()

the.lab <- gsub(" $","",gsub("\\(.*\\)","",d$pasta))
png(file="fig-abcpestimates+rankci.png",width=12,height=6,units="in",res=300)
par(mar=c(9.5,3.5,0.5,0.5))
n <- nrow(d)
d <- d[order(d$ability.abcp,decreasing =T),]
plot(1:n,d$ability.abcp,bty="n",ylim=c(-5.5,0.5),xaxt="n",ylab="",xlab="",cex=0.7)
#abline(h=c(0,d$ability.abcp[n]),lty=2)
#segments(x0=1:n,x1=1:n,
#		y0=d$ability.abcp-1.64*d$s.e..abcp,
#		y1=d$ability.abcp+1.64*d$s.e..abcp)
abline(v=1:n,lty=3,col=gray(0.7))
segments(x0=1:n,x1=1:n,
		y0=d$ability.abcp[d$rank.05.abcp],
		y1=d$ability.abcp[d$rank.95.abcp])
points(1:n,d$ability.abcp,bg="white",pch=21,cex=0.7)
axis(side=1,at=1:n,the.lab,las=2,cex.axis=0.7)
mtext(side=2,line=2.5,"Estimated Worth")
dev.off()



############################################################
## ROBUSTNESS: ELIMINATING EXCESS REPEATED CONTESTS 	  ##
## Included in Supplemental Information packet			  ##
############################################################
library(plyr)
library(BradleyTerry2)

## Load the data and look at excess contests in the Manual versions
load("data-bls.RData")
the.blsM <-  the.blsO <-  the.set
M <- the.blsM$the.set[grep("X",the.blsM$the.set$ref),]#manual start with X
O <- the.blsO$the.set[grep("O",the.blsO$the.set$ref),]#online start with O
M$contests <- paste(M$X1,M$X2,sep="vs")
the.contests <- ddply(M, ~contests,function(x){prop.table(table(x$winX1))})
the.contests$smallN <- round(the.contests[,"TRUE"]*4)

#Define the populations of each of the 19 contests, from which four will be drawn
the.pop <- list()
for(i in 1:nrow(the.contests)){
	the.pop[[the.contests$contests[i]]] <- which(M$contests==the.contests$contests[i])
	}
	
#Draw 4 contests from each of the 19 Manual cases
#append to the online cases, estimate BT
#save and continue 1000 times
simsBT <- matrix(NA,nrow=37,ncol=1000)
set.seed(1977)
for(i in 1:1000){
	the.draw <- do.call("c",lapply(the.pop,sample,4,replace=F))
	sim.set <- rbind(M[the.draw,1:5],O)
	simBT <- BTm(cbind(winX1, winX2), X1, X2, data = sim.set, br = TRUE)
	simBT  <- update(simBT , refcat = "M17")
	simBT <- BTabilities(simBT)
	simsBT[,i] <- simBT[,"ability"] }
rownames(simsBT) <- rownames(simBT)
sims <- data.frame(ability=apply(simsBT,1,mean),s.e.=apply(simsBT,1,sd))
#save(sims,file="out-simulatedBT.RData")

#compare the the full estimates and the simulated estimates
bls <- read.csv("out-BLScabestimates-BT.csv")
bls$rank <- 1:nrow(bls)
rownames(bls) <-  paste("M",sprintf("%02.0f", bls$Code),sep="")
bls <- merge(bls,sims,by=0,suffixes=c("",".sim"))
cor.test(bls$ability,bls$ability.sim)
plot(bls$ability,bls$ability.sim)

jpeg(file="fig-comparesimulation.jpg",res=400,width=8,height=8,units="in")
	par(mar=c(5,5,1,3))
	plot(bls$ability,bls$ability.sim
		,bty="n",type="n",cex=.8
		,xlab="Worth of Portfolio According to Elites"
		,ylab="Simulated Worth\n(eliminating excess contests)")
	reg <- lm(ability.sim~ ability, data=bls)
	abline(reg=reg)
	outliers <-  abs(rstandard(reg))>2
	points(bls$ability,bls$ability.sim
		,pch=ifelse(outliers,21,19)
		,cex=.8)
	text(bls$ability,bls$ability.sim
	,labels=ifelse(outliers,as.character(iconv(as.character(bls$pasta))),NA)
	,cex=0.8
	,pos=1,xpd=NA)
dev.off()


############################################################
## COMPARING ESTIMATES WITH OBJECTIVE INDICATORS		  ##
## Table 2 in main paper								  ##
############################################################
setwd("~/Dropbox/Data/Paper-CabinetValues/Replic")
load("data-objective.RData")			#objective indicators
load("out-BLScabestimates-BT.RData") 	#estimates obtained above
bls <- valbto
load("out-ABCPcabestimates-BT.RData")	#estimates obtained above
abcp <- valbto
valbto <- merge(bls,abcp
	,by=c("Code","Level","pasta")
	,suffixes=c("",".abcp"))
d2 <- merge(mm2,valbto,by="Code",all.x=T) #new table with all information

reg <- lm(ability~LogTotalBudget+InvestBudget+Appointtees+Policy
			,data=d2)
reg.abcp <- lm(ability.abcp~LogTotalBudget+InvestBudget+Appointtees+Policy
			,data=d2)		
d2$pred <- predict(reg)	
d2$pred.abcp <- predict(reg.abcp)			

methods.tab <- cor(subset(d2
	,select=c("ability","ability.abcp","Appointtees","Policy","InvestBudget","LogTotalBudget","pred","pred.abcp")))
xmethods.tab <- xtable(methods.tab[,1:2],
				caption= "Linear Association Between BT Estimates and Observable Indicators",
				label="tab-observable",
				digits=2,align="lcc")
## This is Table 2, after eliminating a few cells
print(xmethods.tab,include.rownames = T
		 ,caption.placement = "top")
write.csv(round(methods.tab[,1:2],2),
	file="tab-methodsnote2.csv",
	row.names=T)