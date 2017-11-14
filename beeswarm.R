#!/usr/bin/env Rscript


## check required packages ##
if (!require(optparse)) {
	devtools::install_github("optparse", "trevorld")
}
if (!require(ggplot2)) {
	install.packages('ggplot2')
}
if (!require(ggbeeswarm)) {
	install.packages('ggbeeswarm')
}
suppressPackageStartupMessages(library(optparse))

option_list <- list(
	make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
		help="Print extra output [default]"),
	make_option(c("-q", "--quiet"), action="store_false",
		dest="verbose", help="Print little output"),
	make_option(c("-d", "--data"), type="character", default=NA,
		help="Input data file,data frame format is needed,one column is the data from a sample,one row is the data from a feature(i.e.,gene,transcript,exon,region).The first column should be the feature name"),
	make_option(c("-f","--featureList"), type="character",default=NA,
		help = "Only features in feature list file will be plot.NOTE,the feature name should be the same as that in the data file."),
	make_option(c("-g","--group"), type="character",default=NA,
		help = "Group file should be supplied to divide the samples into different groups.Sample name in group file should be the same as that in the data file.The first column should be the sample column,the second should be the group column."),
	make_option(c("-o","--outdir"), type="character",default=getwd(),
		help = "Directory where beeswarm plot will be placed."),
	make_option(c("-t","--thread"), type="integer",default=1,
		help = "Thread number used to run the program.")
)
opt <- parse_args(OptionParser(option_list=option_list))

## parse command line options
data <- opt$data
feature.list <- opt$featureList
group <- opt$group
outdir <- opt$outdir

D <- read.delim(data,as.is=T,check.names=F)
M <- data.matrix(D[,-1])
rownames(M) <- D[,1]
feature.df <- read.delim(feature.list,as.is=T,check.names=F)
idx <- match(feature.df[,1],D[,1])
M <- M[idx,]
group.df <- read.delim(group,as.is=T,check.names=F)
group.df <- group.df[,1:2]
colnames(group.df) <- c("sample","group")
for (i in 1:nrow(M)) {
	row.df <- data.frame(count=M[i,],sample=colnames(M))
	row.df <- merge(row.df,group.df,sort=F)
	feature.name <- rownames(M)[i]
	ggplot(row.df, aes(x=group, y=count, color=group)) + geom_boxplot(outlier.shape = NA,lwd=0.2,fatten=1) + geom_beeswarm(size=3,cex=2) + theme_classic()
	ggsave(sprintf("%s/%s.png",outdir,feature.name),w=8,h=6,dpi=600)
}
cat("Program finished successfully.\n")
