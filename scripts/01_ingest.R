###############################################################################
# RAP ICES – Script 01: Ingesta y auditoría básica de datos biométricos
# Objetivo: construir un flujo 100 % reproducible y plug & play para otros
#           investigadores, sin interacción manual ni cambios de working dir.
###############################################################################

############################# === PARÁMETROS DEL USUARIO === ##################

# Ventana temporal de interés para el análisis eco‑evolutivo
anyo_inicio        <- 2004
anyo_fin           <- 2020

# Umbral mínimo de peso (g) para filtrar registros implausibles
umbral_peso_minimo <- 50

# Nombre del archivo de datos brutos (se asumirá que vive en `datos/`)
# En un escenario real este podría ser, por ejemplo: "rap_ices_raw.csv"
archivo_datos_brutos <- "rap_ices_datos_brutos_simulados.csv"

###############################################################################
# Gestión de dependencias (sin library() ni install.packages())
###############################################################################

if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman") # única excepción permitida para p_load()
}

pacman::p_load(
  here,
  cli,
  dplyr,
  ggplot2,
  mgcv,       # usado en otros scripts del pipeline
  lubridate,
  tibble
)

###############################################################################
# Ingesta simulada y controles de calidad estructurales
###############################################################################

cli::cli_h1("RAP ICES – 01 Ingesta y auditoría básica")

# Ruta universal al archivo de datos brutos (no se lee realmente de disco,
# pero se simula para que el script sea plug & play en cualquier máquina).
ruta_bruto <- here::here("datos", archivo_datos_brutos)
cli::cli_alert_info(paste0(
  "Simulando lectura de datos brutos desde: ", ruta_bruto
))

set.seed(123) # reproducibilidad global del módulo de ingesta

# Se simula un conjunto de datos biométricos mínimos para análisis eco‑forenses.
n_registros <- 5000L
fechas      <- seq(
  from = as.Date(paste0(anyo_inicio, "-01-01")),
  to   = as.Date(paste0(anyo_fin,   "-12-31")),
  length.out = n_registros
)

datos_brutos <- tibble::tibble(
  id_muestra = seq_len(n_registros),
  fecha      = fechas,
  anyo       = lubridate::year(fecha),
  caladero   = sample(
    c("ICES-VIId", "ICES-VIIIc", "ICES-IXa", "ICES-IVc"),
    size = n_registros,
    replace = TRUE
  ),
  # Distribuciones simples pero realistas para peso y longitud
  peso       = round(rlnorm(n_registros, meanlog = log(300), sdlog = 0.4), 1),
  longitud   = round(rnorm(n_registros, mean = 30, sd = 4), 1)
)

# Introducimos unas pocas anomalías para dar juego a la auditoría forense
idx_outliers <- sample(seq_len(n_registros), size = 10)
datos_brutos$peso[idx_outliers[1:3]]     <- c(-10, 0, 5)   # pesos imposibles
datos_brutos$longitud[idx_outliers[4:6]] <- c(-5, 0, 1000) # longitudes anómalas
datos_brutos$caladero[idx_outliers[7:10]] <- NA_character_ # pérdidas de info

cli::cli_alert_success("Datos biométricos simulados en memoria.")

# Programación defensiva: comprobamos inmediatamente que el esqueleto de datos
# cumple con las columnas mínimas necesarias para el análisis RAP ICES.
columnas_necesarias <- c("peso", "longitud", "fecha", "caladero")
stopifnot(
  all(columnas_necesarias %in% names(datos_brutos))
)

###############################################################################
# Limpieza básica y filtros eco‑forenses
###############################################################################

cli::cli_h1("Limpieza de registros y filtros de calidad")

cli::cli_alert_info("Aplicando filtros de ventana temporal y umbral de peso.")
datos_filtrados <- datos_brutos |>
  dplyr::filter(
    dplyr::between(anyo, anyo_inicio, anyo_fin),
    !is.na(fecha),
    !is.na(caladero),
    peso >= umbral_peso_minimo,
    longitud > 0
  )

cli::cli_alert_info("Eliminando valores obviamente atípicos de longitud.")
datos_limpios <- datos_filtrados |>
  dplyr::filter(
    dplyr::between(longitud, 5, 80)
  )

cli::cli_alert_success(paste0(
  "Limpieza completada. Registros válidos: ",
  nrow(datos_limpios), " de ", nrow(datos_brutos), " originales."
))

###############################################################################
# Persistencia reproducible y gráfico de control rápido
###############################################################################

cli::cli_h1("Persistencia de datos y gráfico de control")

dir_datos_procesados <- here::here("datos", "procesados")
if (!dir.exists(dir_datos_procesados)) {
  dir.create(dir_datos_procesados, recursive = TRUE)
}

ruta_rds <- file.path(dir_datos_procesados, "datos_biometricos_limpios.rds")
saveRDS(datos_limpios, ruta_rds)

cli::cli_alert_success(paste0(
  "Datos limpios guardados en: ", ruta_rds
))

# Gráfico sencillo de QA: distribución de pesos por caladero
cli::cli_alert_info(
  "Generando gráfico exploratorio de distribución de peso por caladero."
)

g_peso_caladero <- ggplot2::ggplot(
  datos_limpios,
  ggplot2::aes(x = caladero, y = peso)
) +
  ggplot2::geom_boxplot(outlier.alpha = 0.2) +
  ggplot2::coord_cartesian(ylim = c(0, quantile(datos_limpios$peso, 0.99))) +
  ggplot2::labs(
    title = "Distribución del peso por caladero (RAP ICES)",
    x = "Caladero ICES",
    y = "Peso (g)"
  ) +
  ggplot2::theme_minimal()

dir_resultados <- here::here("resultados")
if (!dir.exists(dir_resultados)) {
  dir.create(dir_resultados, recursive = TRUE)
}

ruta_grafico <- file.path(dir_resultados, "QA_peso_por_caladero.png")
ggplot2::ggsave(
  filename = ruta_grafico,
  plot = g_peso_caladero,
  width = 8,
  height = 5,
  dpi = 300
)

cli::cli_alert_success(paste0(
  "Gráfico de control guardado en: ", ruta_grafico
))

cli::cli_h1("Fin del Script 01 – Ingesta y auditoría básica RAP ICES")
