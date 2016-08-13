#! /usr/bin/env Rscript

require("R6")

# R6 class
Salary<-R6Class(
  classname = "Salary",
  private = list(
    # Private Variables
    dbengine = "SQLite",
    sqlname = "display.sql",
    dbname = "salary.sqlite",
    pdfname = "salary_analyze.pdf",
    fontreg = "HiraginoSans-W3",
    fontbol = "HiraginoSans-W5",
    con = NA,

    # Private Methods
    loadModules = function()
    {
      require("RSQLite")
      require("extrafont")
      require("Cairo")
      require("ggplot2")
    },
    gpTheme = function(gp, title.text)
    {
      gp = gp + geom_smooth(method=glm, family=gaussian)
      gp = gp + labs(title=title.text)
      gp = gp + theme_bw()
      gp = gp + theme(panel.grid.minor=element_blank())
      return(gp)
    },
    db.open = function()
    {
      private$con<-
        dbConnect(
          dbDriver(private$dbengine),
          dbname = private$dbname
        )
    },
    getQuery = function()
    {
      self$query<-readChar(
        private$sqlname,
        file.info(private$sqlname)$size
      )
      salary.raw<-dbGetQuery(
        conn = private$con,
        statement = self$query
      )
      self$salary.data<-salary.raw[,3:5]
      row.names(self$salary.data)<-salary.raw[,2]
    },
    db.close = function()
    {
      dbDisconnect(private$con)
    },
    data.load = function()
    {
      private$db.open()
      private$getQuery()
      private$db.close()
    },
    config.font = function()
    {
      par(family=private$fontreg)
      par(xpd=TRUE)
      CairoFonts(
        regular = private$fontreg,
        bold = private$fontbol
      )
    }
  ),
  public = list(
    # Public Variables
    query = NA,
    salary.data = NA,
    prcomp.result = NA,
    hclust.result = NA,
    
    # Constructor Method
    initialize = function()
    {
      private$loadModules()
      private$data.load()
      private$config.font()
    },
    
    # Public Methods
    PDF.open = function(filename=private$pdfname,
                        pdf.height = 9.27,
                        pdf.width = 30
                        )
    {
      CairoPDF(
        file = filename,
        onefile = TRUE,
        paper="a4r",
        height = pdf.height,
        width = pdf.width)
    },
    PDF.close = function()
    {
      dev.off()
    },
    draw.biplot = function()
    {
      self$prcomp.result<-prcomp(self$salary.data, scale=TRUE)
      biplot(self$prcomp.result)
    },
    draw.pairs = function()
    {
      pairs(self$salary.data, pch=16, col="blue")
    },
    draw.dendrogram = function(cluster.method="ward.D2")
    {
      self$hclust.result<-
        hclust(
          dist(self$salary.data),
          method = cluster.method
        )
      summary(self$hclust.result)
      plot(
        self$hclust.result,
        hang=-1,
        sub = paste("Clustering method: ",cluster.method)
      )
    },
    cut.tree = function(k)
    {
      result<-cutree(self$hclust.result)
      print(result)
      self$salary["group.estinate"]<-result
    },
    query.print = function()
    {
      cat(self$query)
    }
  )
)





