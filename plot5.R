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
SCC$SCC.Level.One <- as.character(SCC$SCC.Level.One)
SCC$SCC.Level.Two <- as.character(SCC$SCC.Level.Two)

SCC_motor_veh <- subset(SCC, grepl("Vehicles", SCC.Level.Two), select=c("SCC"))
NEI_Baltimore_motor_veh <- subset(NEI,
                                  fips == 24510 & SCC %in% SCC_motor_veh$SCC,
                                  select=c(Emissions, year))
emissions_per_year_vector <- with(NEI_Baltimore_motor_veh, tapply(Emissions, year, sum))
total_emissions_motor_veh_baltimore <- data.frame(Emissions=unname(emissions_per_year_vector),
                                                  year=names(emissions_per_year_vector))

library(ggplot2)
library(grid)

qplot(year, Emissions,
      data=total_emissions_motor_veh_baltimore,
      geom="line",
      group=1,
      margins=T,
      main="Total PM2.5 emissions from motor vehicles in Baltimore City",
      ylab="Total PM2.5 emissions, tons") +
  theme(plot.title=element_text(size=13, face="bold", vjust=4)) +
  theme(plot.margin=unit(c(1.5,1.5,0,0), "cm"))

dev.copy(png, "plot5.png")
dev.off()
