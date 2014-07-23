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

NEI_Baltimore_1999 <- subset(NEI, year == 1999 & fips == 24510, select=c(Emissions))
NEI_Baltimore_2002 <- subset(NEI, year == 2002 & fips == 24510, select=c(Emissions))
NEI_Baltimore_2005 <- subset(NEI, year == 2005 & fips == 24510, select=c(Emissions))
NEI_Baltimore_2008 <- subset(NEI, year == 2008 & fips == 24510, select=c(Emissions))

total_emissions <- c(sum(NEI_Baltimore_1999$Emissions),
                     sum(NEI_Baltimore_2002$Emissions),
                     sum(NEI_Baltimore_2005$Emissions),
                     sum(NEI_Baltimore_2008$Emissions))

total_emissions_per_year <- data.frame(Emissions=total_emissions,
                                       year=c(1999, 2002, 2005, 2008))

options(scipen=7)
par(mar=c(5,7.5,4,6) + 0.1)
plot(total_emissions_per_year$year, total_emissions_per_year$Emissions,
     type="b",
     lwd=3,
     main="PM2.5 total emissions in Baltimore City",
     xaxt="n",
     yaxt="n",
     xlab="year",
     ylab="")
axis(1, at=total_emissions_per_year$year, las=0)
axis(2, las=2)
mtext("PM2.5 total emissions, tons", side=2, line=6)

dev.copy(png, 'plot2.png')
dev.off()
