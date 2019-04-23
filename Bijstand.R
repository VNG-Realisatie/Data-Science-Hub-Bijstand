#-------------------------------------------------------------------------------
# Analyse Bijstand
# data import, -preparation, -visualisation 
# auteur : Luc van Schijndel, gemeente Nissewaard
# modificaties : Mark Gremmen, Data Science Hub / VNG
# lud 2019-04-23
#-------------------------------------------------------------------------------

# Libraries

#packages
packages <- c("haven","tidyverse", "lubridate", "readxl")
#if packages are not available on your computing set-up then remove bracket from next line, and afterwards re-instate bracket
#install.packages(packages)
lapply(packages,library,character.only = TRUE)
#review
sessionInfo()

#-------------------------------------------------------------------------------
# Global settings

#gemeentenaam
gemeente <- "gemeente XXX"
#onderwerp analyse
analyse <- "Bijstand"

#analyse / presentatie periode
period_start <- 2008 #aanpassen
period_end <- 2018 #aanpassen
bijstands_jaren=period_end-period_start

#root locatie van deze procedure (workdirectory)
root <- getwd()
root

#(import)locatie data-bestanden, Creeer de map eerst
data.loc <- paste0(root,'/DATA/')

#(export)locatie grafieken en andere visualisaties, Creeer de map eerst
plots.loc <- paste0(root,'/PLOTS/')

#dimensie grafieken
graph_height <- 8
aspect_ratio <- 2.5 # breedte = graph_height * aspect_ratio

#prefix titel grafieken 
subject.nme <- paste0(analyse,' ', period_end, ' ', gemeente, ' ')

#-------------------------------------------------------------------------------
# Data import


# I. Omschrijvingen 
# Lees xlsx-datasheet in met omschrijvingen voor code oorzaak bijstandsafhankelijkheid
# Pas de range aan zodat deze de kolommen met daarin de code (numeriek) en omschrijving (tekst) omvat

description.loc <- paste0(data.loc,"2018-07-09 Code oorzaak bijstandsafhandelijkheid.xlsx") #aanpassen

BijstandOmschrijvingReden <- read_excel(description.loc,
                                        range = "A2:B34", col_names = TRUE, 
                                        col_types = c("numeric", "text"))

# II. Klantenbestand
#minimaal omvat de dataset van het klantenbestand onderstaande variabelen met exact de volgende 
#variabelenamen:
#geboortejaar, geslacht, startdatum, einddatum, Omschrijving leefvorm

#voorbeeld : 
#geboortejaar (1976)
#geslacht (man)
#startdatum (2008-05-04)
#einddatum (2008-08-04)
#Omschrijving leefvorm (Alleenstaande)
#Oorzaak bijstandsafhankelijkheid (code)

# Lees het klantenbestand in met gegevens van bijstandsuitkering
#(3 opties)
# Pas bestandsnaam en -extensie (rds,csv,xlsx,sav) aan. Default = rds

population.loc <- paste0(data.loc,"DummyDataBijstandv3.rds") #aanpassen


# Optie I : R-data (rds)
BijstandBron <-  read_rds(population.loc)

# Optie II : Comma separated values (csv)
#BijstandBron <- read.csv(file=population.loc, header=TRUE, sep=",")

# Optie III : Microsoft Excel (Xlsx)
#BijstandBron <- read_excel(file=population.loc, col_names = TRUE)

# Optie IV : IBM SPSS (sav) 
#BijstandBron <- read_spss(population.loc)

#meta-data (before)
str(BijstandBron)
#head(BijstandBron)

#-------------------------------------------------------------------------------
# Data preparation


BijstandAnalyse <- BijstandBron %>%
                mutate(instroomjaar = year(startdatum), # nieuwe kolom instroomjaar,
                       leeftijd = year(as.period(interval(as.POSIXct(paste0(geboortejaar, "-07-01"), tz = "UTC"),
                                           startdatum))),
                       LeeftijdsKlasse = case_when( # nieuwe kolom LeeftijdsKlasse
                         leeftijd < 30 ~ "< 30",
                         leeftijd <= 50 ~ "30-50",
                         leeftijd > 50 ~ "50+",
                         TRUE ~ "Error"),
                       LeeftijdGeslacht = paste(geslacht, LeeftijdsKlasse), # nieuwe kolom LeeftijdGeslacht
                       Actief = case_when( # nieuwe kolom actief - is een uitkering nog actief
                         is.na(einddatum) ~ TRUE,
                         TRUE ~ FALSE))

BijstandAnalyse <- BijstandAnalyse %>%
  merge(BijstandOmschrijvingReden, # Voeg omschrijving oorzaak bijstandsafhankelijkheid toe
        by.x = "Oorzaak bijstandsafhankelijkheid", #variabelenaam conform de dataset klantenbestand
        by.y = "Code oorzaak bijstandsafhankelijkheid", #variabelenaam conform dataset omschrijvingen
        all.x = TRUE, all.y = FALSE) 

# Opslaan van het bewerkte bronbestand 
analyse.loc <- paste0(data.loc,"BijstandAnalyse.rds")
write_rds(BijstandAnalyse, analyse.loc,compress = "none")

#bronbestand verwijderen uit het geheugen 
rm(BijstandBron)
#omschrijvingen verwijderen uit het geheugen 
rm(BijstandOmschrijvingReden)

#meta-data (after)
str(BijstandAnalyse)
#head(BijstandAnalyse)

sapply(BijstandAnalyse, function(x) sum(is.na(x)))

#-------------------------------------------------------------------------------
# Data analyse


# Bestand (abs.) naar leeftijd en leefvorm
LeeftijdLeefvorm <- subset(BijstandAnalyse,Actief=='TRUE') %>%
                      group_by(LeeftijdsKlasse, `Omschrijving leefvorm`) %>%
                      summarize(SumActief = sum(Actief))


# Grafiek leeftijd en leefvorm bijstandsgerechtigden
plot.title = paste0(subject.nme,' Leeftijd en leefvorm',' ')

LeeftijdLeefvormplot <- ggplot(LeeftijdLeefvorm, aes(y=SumActief, x=LeeftijdsKlasse, color=LeeftijdsKlasse, fill=LeeftijdsKlasse)) + 
  geom_bar( stat="identity") +    
  facet_wrap(~`Omschrijving leefvorm`) + 
  ggtitle(plot.title)

LeeftijdLeefvormplot
plot.nme = paste0(plot.title,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, height = graph_height , width = graph_height * aspect_ratio)




# Bereken percentage nog actieve uitkeringen per instroomreden per jaar
InstroomPerRedenPerJaar <- BijstandAnalyse %>%
                              group_by(instroomjaar, `Omschrijving oorzaak bijstandsafhankelijkheid`) %>%
                              summarize(PercentageActief = mean(Actief))

# Grafiek van percentage nog actieve uitkeringen per instroomreden per jaar
plot.title = paste0(subject.nme,' Actieve uitkeringen per instroomreden',' ')

InstroomRedenPercActiefplot <- ggplot(InstroomPerRedenPerJaar, aes(x = instroomjaar, y = PercentageActief,
                                                          colour = factor(`Omschrijving oorzaak bijstandsafhankelijkheid`))) +
  ggtitle(plot.title) +
  geom_line(size = 1) + scale_x_reverse(breaks = period_start:period_end) + theme(legend.title = element_blank(),
                                                                    legend.position = c(0.8, 0.77))

InstroomRedenPercActiefplot
plot.nme = paste0(plot.title,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, height = graph_height , width = graph_height * aspect_ratio)



# I. Bereken percentage nog actieve uitkeringen per leefvorm per jaar

InstroomPerLeefvormPerJaar <- BijstandAnalyse %>%
                              group_by(instroomjaar, `Omschrijving leefvorm`) %>%
                              summarize(PercentageActief = mean(Actief))


# Grafiek van percentage nog actieve uitkeringen per leefvorm per jaar
plot.title = paste0(subject.nme,' Actieve uitkeringen per leefvorm',' ')

LeefvormPercActiefplot <- ggplot(InstroomPerLeefvormPerJaar, aes(x = instroomjaar, y = PercentageActief,
                                                                 colour = factor(`Omschrijving leefvorm`))) +
  ggtitle(plot.title) +
  geom_line(size = 1) + scale_x_reverse(breaks = period_start:period_end) + theme(legend.title = element_blank(),
                                                  legend.position = c(0.8, 0.77))

LeefvormPercActiefplot
plot.nme = paste0(plot.title,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, height = graph_height , width = graph_height * aspect_ratio)



# II. Bereken percentage nog actieve uitkeringen per geslacht per jaar

InstroomPerGeslachtPerJaar <- BijstandAnalyse %>%
                              group_by(instroomjaar, geslacht) %>%
                              summarize(PercentageActief = mean(Actief))

# Grafiek van percentage nog actieve uitkeringen per geslacht per jaar
plot.title = paste0(subject.nme,' Actieve uitkeringen per geslacht',' ')

GeslachtPercActiefplot <- ggplot(InstroomPerGeslachtPerJaar, aes(x = instroomjaar, y = PercentageActief,
                                                                 colour = geslacht)) +
  ggtitle(plot.title) +
  geom_line(size = 1) + scale_x_reverse(breaks = period_start:period_end) + theme(legend.title = element_blank(),
                                                  legend.position = c(0.8, 0.77))

GeslachtPercActiefplot
plot.nme = paste0(plot.title,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, height = graph_height , width = graph_height * aspect_ratio)



# III. Bereken percentage nog actieve uitkeringen per leeftijdsklasse per jaar

InstroomPerLeeftijdsklassePerJaar <- BijstandAnalyse %>%
  group_by(instroomjaar, LeeftijdsKlasse) %>%
  summarize(PercentageActief = mean(Actief))

# Grafiek van percentage nog actieve uitkeringen per leeftijdsklasse per jaar
plot.title = paste0(subject.nme,' Actieve uitkeringen per leeftijdsklasse',' ')

LeeftijdsklassePercActiefplot <- ggplot(InstroomPerLeeftijdsklassePerJaar, aes(x = instroomjaar, y = PercentageActief,
                                                                 colour = LeeftijdsKlasse)) +
  ggtitle(plot.title) +
  geom_line(size = 1) + scale_x_reverse(breaks = period_start:period_end) + theme(legend.title = element_blank(),
                                                  legend.position = c(0.8, 0.77))

LeeftijdsklassePercActiefplot
plot.nme = paste0(plot.title,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, height = graph_height , width = graph_height * aspect_ratio)



# Bereken percentage nog actieve uitkeringen per leeftijdsklasse per jaar

InstroomPerLeeftijdGeslachtPerJaar <- BijstandAnalyse %>%
  group_by(instroomjaar, LeeftijdGeslacht) %>%
  summarize(PercentageActief = mean(Actief))

# Grafiek van percentage nog actieve uitkeringen per Leeftijdsklasse - geslacht combinate per jaar
plot.title = paste0(subject.nme,' Actieve uitkeringen per leeftijdsklasse - geslacht combo',' ')

LeeftijdGeslachtPercActiefplot <- ggplot(InstroomPerLeeftijdGeslachtPerJaar, aes(x = instroomjaar, y = PercentageActief,
                                                                               colour = LeeftijdGeslacht)) +
  ggtitle(plot.title) +
  geom_line(size = 1) + scale_x_reverse(breaks = period_start:period_end) + theme(legend.title = element_blank(),
                                                  legend.position = c(0.8, 0.77))

LeeftijdGeslachtPercActiefplot
plot.nme = paste0(plot.title,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, height = graph_height , width = graph_height * aspect_ratio)


# Verschillen tussen cohorten (jaargroepen)

# Voeg kolommen toe voor actief na (1-9) jaar

for(i in 1:bijstands_jaren) {
  colname <- paste0("ActiefNaJaar", i)
  BijstandAnalyse[,colname] <- BijstandAnalyse$startdatum %m+% years(i) < BijstandAnalyse$einddatum
  BijstandAnalyse[is.na(BijstandAnalyse$einddatum) &
                         BijstandAnalyse$startdatum %m+% years(i) < as.POSIXct("2018-07-09", tz = "UTC"),
                       colname] <- TRUE
  BijstandAnalyse[,colname] <- as.integer(BijstandAnalyse[,colname])
}

# Bereken percentage nog actieve uitkeringen per cohort per aantal jaren na start

BijstandAnalyseCohortenAlt <- BijstandAnalyse %>%
                           select(append("instroomjaar", paste0("ActiefNaJaar", 1:bijstands_jaren))) %>%
                           gather(key = "Jaren in Bijstand", value = "Actief", -instroomjaar) %>%
                           mutate(`Jaren in Bijstand` = parse_number(`Jaren in Bijstand`)) %>%
                           group_by(instroomjaar, `Jaren in Bijstand`) %>%
                           summarize(PercActief = mean(Actief))
# opslaan bijgewerkte analysebestand
write_rds(BijstandAnalyse, analyse.loc,compress = "none")

# Grafiek van percentage nog actieve uitkeringen per cohort per aantal jaren na start
plot.title = paste0(subject.nme,' Actieve uitkeringen per cohort per aantal jaren na start',' ')

PercActiefCohortplot <- ggplot(BijstandAnalyseCohortenAlt, aes(x = `Jaren in Bijstand`, y = PercActief,
                                                               colour = factor(instroomjaar))) +
  ggtitle(plot.title) +
  scale_x_continuous(breaks = seq(1, bijstands_jaren, 1), lim = c(1, bijstands_jaren)) +
  geom_line(size = 1) + theme(legend.title = element_blank(),
                              legend.position = c(0.8, 0.6))


PercActiefCohortplot
plot.nme = paste0(plot.title,'.png')
plot.store <-paste0(plots.loc,plot.nme)
ggsave(plot.store, height = graph_height , width = graph_height * aspect_ratio)


