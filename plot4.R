emissions_file <- 'summarySCC_PM25.rds'
scc_table_file <- 'Source_Classification_Code.rds'

if (!file.exists(emissions_file) | !file.exists(scc_table_file)) {
  tmpfile <- tempfile()
  download.file(url='https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip',
                destfile=tmpfile)
  unzip(tmpfile)
  unlink(tmpfile)
}

NEI <- readRDS(emissions_file)
SCC <- readRDS(scc_table_file)
SCC$Short.Name <- as.character(SCC$Short.Name)

SCC_coal_comb <- subset(SCC, grepl("Coal", Short.Name) & grepl("Comb", Short.Name), select=c("SCC"))
emissions_coal_comb <- subset(NEI, 
                              year >= 1999 & year <= 2008 & SCC %in% SCC_coal_comb$SCC, 
                              select=c("Emissions", "year"))
total_emissions_vector <- with(emissions_coal_comb,
                               tapply(Emissions, year, sum))
total_emissions_coal_comb_per_year <- data.frame(Emissions=unname(total_emissions_vector),
                                                 year=names(total_emissions_vector))

library(ggplot2)
library(grid)

qplot(year, Emissions,
      data=total_emissions_coal_comb_per_year,
      geom="line",
      group=1,
      margins=T,
      main="Total PM2.5 emissions for coal combustion-related sources in the USA",
      ylab="Total PM2.5 emissions, tons") +
  theme(plot.title=element_text(size=13, face="bold", vjust=4)) +
  theme(plot.margin=unit(c(1.5,1.5,0,0), "cm"))

dev.copy(png, "plot4.png")
dev.off()
