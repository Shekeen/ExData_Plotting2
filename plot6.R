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
                                  fips == "24510" & SCC %in% SCC_motor_veh$SCC,
                                  select=c(Emissions, year))
NEI_LA_County_motor_veh <- subset(NEI,
                                  fips == "06037" & SCC %in% SCC_motor_veh$SCC,
                                  select=c(Emissions, year))
emissions_per_year_balt_vector <- with(NEI_Baltimore_motor_veh, tapply(Emissions, year, sum))
emissions_per_year_la_vector <- with(NEI_LA_County_motor_veh, tapply(Emissions, year, sum))
total_emissions_motor_veh_baltimore <- data.frame(place=as.factor("Baltimore"),
                                                  Emissions=unname(emissions_per_year_balt_vector),
                                                  year=names(emissions_per_year_balt_vector))
total_emissions_motor_veh_la <- data.frame(place=as.factor("LA_County"),
                                           Emissions=unname(emissions_per_year_la_vector),
                                           year=names(emissions_per_year_la_vector))

emission_difference_bal <- total_emissions_motor_veh_baltimore$Emissions[2:4] - 
                           total_emissions_motor_veh_baltimore$Emissions[1:3]
emission_difference_la <- total_emissions_motor_veh_la$Emissions[2:4] - 
                          total_emissions_motor_veh_la$Emissions[1:3]
emission_difference <- rbind(data.frame(place="Baltimore",
                                        EmissionDifference=emission_difference_bal,
                                        years=c("1998-2002", "2002-2005", "2005-2008")),
                             data.frame(place="LA County",
                                        EmissionDifference=emission_difference_la,
                                        years=c("1998-2002", "2002-2005", "2005-2008")))

library(ggplot2)
library(grid)

ggplot(emission_difference,
       aes(x=years, y=EmissionDifference, fill=place)) +
  geom_bar(position="dodge", stat="identity") +
  ggtitle("Difference in PM2.5 emission by motor vehicles\nacross various years")

dev.copy(png, "plot6.png")
dev.off()
