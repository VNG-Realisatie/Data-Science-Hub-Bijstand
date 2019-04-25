# Data-Science-Hub-Bijstand
Sturen op bijstand


Eind April 2019 start het traject 'Sturen op bijstand' via het Data Science Hub van VNG Realisatie. Daarin bieden we gemeenten de mogelijkheid om snel inzicht te verkrijgen in de bestandsopbouw van de registratie voor bijstandsgerechtigden.

 

Een kant-en-klaar basisscript in R-Statistics, ontwikkeld door de gemeente Nissewaard, geeft het verloop van het klantenbestand Bijstand in de tijd weer op basis van de belangrijkste kenmerken en omstandigheden van een bijstandsgerechtigde. Het script vormt een uitgangspunt om direct het eigen klantenbestand te analyseren en aanvullende inzichten in te beleggen. De uniforme opzet en output maakt dat de inzichten ook goed te vergelijken zijn met andere gemeenten.

 

Het doel van het Data Science-traject is om zelf meer hands-on ervaring op te bouwen met bestandsanalyse op basis van R Statistics. Daarin willen we verkennen welke aanvullende behoeften er zijn voor bestandsanalyse en gezamenlijk een aandeel nemen in het doorontwikkelen van de beschikbaar gestelde analyse. De ervaringen en inzichten uit de bestandsanalyse worden onderling gedeeld en vormen de inzet voor discussie over doeltreffende vormen van re-integratie.

 

Het traject bestaat uit een webinar en een bijeenkomst.

 

Looptijd: begin April tot en met de tweede week van Mei

Bijeenkomst(en):

Webinar 25 april 10.00-10.30h

(Slot)bijeenkomst 16 mei 9.30-12.00h (Data Science Hub @ JADS in Den Bosch)


Wat vraagt deelname van een gemeente?
-basisvaardigheden in en infrastructuur voor het gebruik van R Statistics & R Studio
-afvaardiging van twee personen (analist en inhoudsdeskundige/beleidsmedewerker)
-toepassen van het script op eigen klantenbestand
-delen van de inzichten
-actieve inzet om de bestandsanalyse te verdiepen

 

Meedoen?!

Geef je dan snel op bij John van Ameijde, john.vanameijde@vng.nl.



_________________________________________________________________________________________________________________________________


Dit R-script maakt inzichtelijk hoe de opbouw van het klantenbestand er uitziet alsmede het verloop van de uitstroom van bijstandsclienten door de jaren heen:

7 visualisaties:
-opbouw klantenbestand naar leeftijd, leefvorm
-instroomreden
-leefvorm
-geslacht 
-leeftijdsklasse 
-leeftijdsklasse - geslacht combinatie 
-cohort per aantal jaren na start 

Het R-script is voorzien van beschrijving alsmede een dummy-databestand en codelijst 'oorzaak bijstandsafhankelijkheid'. 

Het materiaal is beschikbaar gesteld door Luc van Schijndel, gemeente Nissewaard.

De ondersteuning en begeleiding in dit project is ondergebracht bij het Data Science Hub van VNG Realisatie. Voor meer informatie, opmerkingen en vragen over dit project, ga naar: https://forum.vng.nl/ (aanmelden voor forum: Data Science Hub) Zie vervolgens het menu-item projecten.




_________________________________________________________________________________________________________________________________


Voor de analyse vormt het R Statistics bestand 'Bijstand-MD.Rmd'*  het uitgangspunt.
Maak allereerst twee mappen aan op de locatie waar het script wordt geplaatst:
"DATA" en "PLOTS"
Het script maakt gebruik van twee databestanden: 
 1. het databestand met klantregistratie (er zijn verschillende methoden in het script om bestandstypen in te lezen),
 2. de xsl-sheet met daarin de omschrijvingen
Plaats beide bestanden in de map "DATA" en pas de namen van beide bestanden aan in het script. 

Pas vervolgens de overige instellingen bovenin het script aan (w.o. analyseperiode)

Ten slotte, run de code  

*) Markdown versie van het R-statistics script: hierin is een meer uitvoerige beschrijving van de procedure opgenomen. Het biedt aanvullend de mogelijkheid om een output file in html te genereren waarin uiteenzetting, code, en visualisatie samenkomen.  
