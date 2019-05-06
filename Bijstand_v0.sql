/* 
SQL query om BijstandBron samen te stellen voor Bestandsanalyse Bijstand
LET OP concept. Output nog niet gecontroleerd.
Datum: 6-5-2019 (aanpassing labels conform R-script)
Doel : output naar csv of txt of xls tbv van analyse bijstand.
*/


Select
  szdos.Dossiernr                           "Dossiernr"
, szclient.Clientnr                         "Clientnummer"
, Extract(Year From Szclient.Dd_Geboorte)   "geboortejaar"
, szclient.Ind_Geslacht                     "geslacht"
-- Dossiergegvens
, szbpdos.Ind_Cli_Type                      "Type"
, szdos.Dd_St_Per_Alg                       "Startdatum periodiek algemeen" 
, szdos.Dd_End_Per_Alg                      "Einddatum periodiek algemeen"
, szdos.Ind_Samenl                          "Indicatie leefvorm" 
, szdomeinref.Omschryving                   "Omschrijving leefvorm"
, szdos.Kode_Afh                            "Oorzaak bijstandsafhankelijkheid"
, szafh.oms_afh                             "Omschrijving oorzaak bijstandsafhankelijkheid"
, szeind.Omschryving                        "Omschrijving einde bijstandsafhankelijkheid"
from szclient  

join szbpdos          On Szclient.Clientnr = Szbpdos.Clientnr -- bijstandpartij, 1 dossier kan meerdere personen bevatten.

join Szdos            On Szbpdos.Dossiernr =Szdos.Dossiernr 
                        And Szdos.Kode_Regeling =0 
                        And Szdos.Dd_St_Per_Alg Is Not Null
                        -- filters actief niet actief
                        --and szdos.dd_st_per_alg is not null
                        --and ( szdos.dd_end_per_alg is null  or szdos.dd_end_per_alg  > sysdate)

join szdomeinref      On szdomeinref.Domein_Naam='D_UIT_IND_SAMENL' And Szdomeinref.Kode =Szdos.Ind_Samenl
left join szafh       On szdos.Kode_Afh = Szafh.Kode_Afh   --and SZAFHAND.omschryving is null
left join szeind      On szeind.Ind_Reden_Einde =  Szdos.Kode_Rede_Eind
order by 1
