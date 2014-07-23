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

NEI_Baltimore_1999 <- subset(NEI, year == 1999 & fips == 24510, select=c(Emissions, type))
NEI_Baltimore_2002 <- subset(NEI, year == 2002 & fips == 24510, select=c(Emissions, type))
NEI_Baltimore_2005 <- subset(NEI, year == 2005 & fips == 24510, select=c(Emissions, type))
NEI_Baltimore_2008 <- subset(NEI, year == 2008 & fips == 24510, select=c(Emissions, type))

emission_by_type_per_year <- rbind(data.frame(Emissions=unname(with(NEI_Baltimore_1999, tapply(Emissions, type, sum))),
                                              type=names(with(NEI_Baltimore_1999, tapply(Emissions, type, sum))),
                                              year=1999),
                                   data.frame(Emissions=unname(with(NEI_Baltimore_2002, tapply(Emissions, type, sum))),
                                              type=names(with(NEI_Baltimore_2002, tapply(Emissions, type, sum))),
                                              year=2002),
                                   data.frame(Emissions=unname(with(NEI_Baltimore_2005, tapply(Emissions, type, sum))),
                                              type=names(with(NEI_Baltimore_2005, tapply(Emissions, type, sum))),
                                              year=2005),
                                   data.frame(Emissions=unname(with(NEI_Baltimore_2008, tapply(Emissions, type, sum))),
                                              type=names(with(NEI_Baltimore_2008, tapply(Emissions, type, sum))),
                                              year=2008))

library(ggplot2)

ggplot(emission_by_type_per_year,
       aes(x=year, y=Emissions, color=type, group=type)) + geom_line()

dev.copy(png, "plot3.png")
dev.off()
