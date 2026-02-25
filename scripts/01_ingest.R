# Script de ingesta y limpieza

# Cargar librerías necesarias
library(dplyr)
library(lubridate)

# Generar fechas diarias desde 2010 a 2024
fechas <- seq(as.Date("2010-01-01"), as.Date("2024-12-31"), by = "day")
n <- length(fechas)

# Generar datos simulados con patrones realistas
set.seed(123) # Para reproducibilidad

# Temperatura: ciclo estacional + tendencia alcista + ruido
dias_del_ano <- yday(fechas)
temperatura <- 10 + 
  8 * sin(2 * pi * dias_del_ano / 365.25) +  # Ciclo estacional
  0.02 * (1:n) +  # Tendencia alcista (calentamiento)
  rnorm(n, mean = 0, sd = 2)  # Ruido aleatorio

# Plancton: picos en primavera (marzo-mayo) + ruido
plancton <- 50 + 
  30 * sin(2 * pi * (dias_del_ano - 80) / 365.25) +  # Pico en primavera
  pmax(0, rnorm(n, mean = 0, sd = 10))  # Solo valores positivos

# Nitratos: variación estacional más suave + ruido
nitratos <- 5 + 
  2 * sin(2 * pi * dias_del_ano / 365.25) + 
  rnorm(n, mean = 0, sd = 0.5)

# Crear dataframe base
master_data <- data.frame(
  fecha = fechas,
  temperatura = round(temperatura, 2),
  plancton = round(plancton, 2),
  nitratos = round(nitratos, 2)
)

# Introducir 5 outliers artificiales para probar la auditoría
set.seed(456) # Semilla diferente para outliers

# Outlier 1: Temperatura extremadamente alta (35ºC en invierno)
idx1 <- sample(which(month(fechas) %in% c(12, 1, 2)), 1)
master_data$temperatura[idx1] <- 35.0

# Outlier 2: Plancton negativo (imposible físicamente)
idx2 <- sample(1:n, 1)
master_data$plancton[idx2] <- -15.5

# Outlier 3: Nitratos extremadamente altos
idx3 <- sample(1:n, 1)
master_data$nitratos[idx3] <- 25.0

# Outlier 4: Temperatura extremadamente baja en verano
idx4 <- sample(which(month(fechas) %in% c(6, 7, 8)), 1)
master_data$temperatura[idx4] <- -5.0

# Outlier 5: Plancton extremadamente alto (bloom anómalo)
idx5 <- sample(which(month(fechas) %in% c(10, 11)), 1)
master_data$plancton[idx5] <- 500.0

# Guardar datos procesados
if (!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
}

saveRDS(master_data, "data/processed/master_data.rds")

cat("Datos generados exitosamente.\n")
cat("Total de registros:", nrow(master_data), "\n")
cat("Rango de fechas:", min(master_data$fecha), "a", max(master_data$fecha), "\n")
cat("Outliers introducidos en filas:", idx1, idx2, idx3, idx4, idx5, "\n")
