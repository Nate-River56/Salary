#! /usr/bin/env Rscript
require("RSQLite")
require("extrafont")
require("Cairo")

par(family="HiraginoSans-W3")
par(xpd=TRUE)

CairoFonts(regular = "HiraginoSans-W3", bold = "HiraginoSans-W5")

con<-dbConnect(dbDriver("SQLite"), dbname="salary.sqlite")

filename<-"display.sql"
query<-readChar(filename,file.info(filename)$size)
salary<-dbGetQuery(con,statement = query)

dbDisconnect(con)

salary2<-salary[,3:5]
row.names(salary2)<-salary[,2]

result<-prcomp(salary2, scale=TRUE)

CairoPDF(file = "salary_analyze.pdf", onefile = TRUE, paper="a4r", height = 9.27, width = 30)
pairs(salary2, pch=16, col="blue")
biplot(result)
plot(hclust(dist(salary2)),hang=-1)

dev.off()




