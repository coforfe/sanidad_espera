#------------------------------------------
# Author: Carlos Ortega
# Date: 2017_01_29
# Purpose: To scrap Madrid's Hospitals waiting list
# Input: Community URL
# Output: data.frame (res_out) with:
# hospital - speciality - date - Total values - Avg values
#------------------------------------------

# Packages Loading
library(RSelenium)
library(seleniumPipes)
library(XML)
library(magrittr)
library(stringr)

# Start Selenium Server 
rD <- rsDriver( browser = "chrome")
remDr <- rD[["client"]]


basePage <- "https://servicioselectronicos.sanidadmadrid.org/LEQ/Consulta.aspx"

remDr$navigate(basePage)


hospital <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlHospital"]/option[XX]')
especial <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlEspecialidad"]/option[YY]')
fecha    <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlFecha"]/option')
enviar   <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_lbtnBuscar"]')
indicado <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_lblIndicadores"]')
reinicio <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_LinkButton1"]')

#  Initialize variables
res_out <- data.frame(hosp = 0, espe = 0, fech = 0, tot = 0, avg = 0)
cont <- 0
 
for (i in 1:29) {
    for (j in 1:10) {
      print(c(i,j))
     
       # Values with errors
       if (i == 21 & j == 7) { next } 
       if (i == 21 & j == 9) { next } 
       if (i == 23 & j == 2) { next } 
      
      cont <- cont + 1 
new_hosp <- str_replace(hospital, "XX", i)
new_espe <- str_replace(especial, "YY", j)

remDr$findElement(using = 'xpath', value = new_hosp)$clickElement()
val_hos <- unlist(remDr$findElement(using = 'xpath', value = new_hosp)$getElementText()) 

remDr$findElement(using = 'xpath', value = new_espe)$clickElement()
val_esp <- unlist(remDr$findElement(using = 'xpath', value = new_espe)$getElementText()) 
# Avoid error with Odontoestomatología
if (val_esp == "Odontoestomatología") { 
                                        cont <- cont - 1
                                        next 
                                      }

remDr$findElement(using = 'xpath', value = fecha)$clickElement()
val_fec <- unlist(remDr$findElement(using = 'xpath', value = fecha)$getElementText()) 

remDr$findElement(using = 'xpath', value = enviar)$clickElement()
dat_out <- remDr$findElement(using = 'xpath', value = indicado)$getElementText()
dat_out <- unlist(dat_out)
dat_tot <- word(dat_out, 1, sep = fixed('\n\n'))
dat_avg <- word(dat_out, 2, sep = fixed('\n\n'))
dat_tot_end <- as.numeric(word(dat_tot, 2, sep = fixed(':')))
dat_avg_end <- as.numeric( str_replace(str_trim(word(dat_avg, 2, sep = fixed(':')), 'both') , ",", "\\."))

remDr$findElement(using = 'xpath', value = reinicio)$clickElement()

res_out[cont, 1] <- val_hos
res_out[cont, 2] <- val_esp
res_out[cont, 3] <- val_fec
res_out[cont, 4] <- dat_tot_end
res_out[cont, 5] <- dat_avg_end

res_out

if (val_esp == "Total") { break }

 } #j
} #i


remDr$close()
# stop the selenium server
rD[["server"]]$stop() 

write.table( kk, file = "Listas_Espera__Madrid_.csv", sep = ";", row.names = FALSE )


