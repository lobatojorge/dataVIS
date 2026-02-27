###############################################################################
# RAP ICES – Script 03: Modelización (GAM) y productos gráficos
# Objetivo: ajustar modelos eco‑evolutivos reproducibles sobre los datos
#           auditados y generar salidas gráficas listas para informes.
###############################################################################

############################# === PARÁMETROS DEL USUARIO === ##################

# Ventana temporal coherente con el resto del pipeline
anyo_inicio        <- 2004
anyo_fin           <- 2020

# Umbral mínimo de peso empleado también en la fase de ingesta
umbral_peso_minimo <- 50

# Nombre del archivo con datos auditados/procesados generado por 01_ingest.R
archivo_datos_auditados <- "datos_biometricos_limpios.rds"

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
  mgcv
)

###############################################################################
# Lectura de datos auditados y comprobaciones defensivas
###############################################################################

cli::cli_h1("RAP ICES – 03 Modelización GAM y salidas gráficas")

ruta_auditados <- here::here("datos", "procesados", archivo_datos_auditados)
cli::cli_alert_info(paste0(
  "Leyendo datos auditados desde: ", ruta_auditados
))

datos <- readRDS(ruta_auditados)

# Comprobamos inmediatamente que el dataframe conserva las columnas críticas
columnas_necesarias <- c("peso", "longitud", "fecha", "caladero")
stopifnot(
  is.data.frame(datos),
  all(columnas_necesarias %in% names(datos))
)

cli::cli_alert_success("Datos auditados cargados y verificados.")

###############################################################################
# Preparación de covariables para modelos GAM
###############################################################################

cli::cli_h1("Preparación de covariables para modelización")
cli::cli_alert_info("Derivando variables temporales y filtrando rangos de interés.")

datos_modelo <- datos |>
  dplyr::mutate(
    anyo = as.integer(format(fecha, "%Y"))
  ) |>
  dplyr::filter(
    dplyr::between(anyo, anyo_inicio, anyo_fin),
    peso >= umbral_peso_minimo
  )

stopifnot(nrow(datos_modelo) > 0)

cli::cli_alert_success(paste0(
  "Preparación completada. Registros disponibles para modelos: ",
  nrow(datos_modelo)
))

###############################################################################
# Ajuste de modelos GAM eco‑evolutivos
###############################################################################

cli::cli_h1("Ajuste de modelos GAM")
cli::cli_alert_info("Ajustando un GAM simple de peso ~ longitud + año.")

modelo_gam_peso <- mgcv::gam(
  peso ~
    mgcv::s(longitud, k = 10) +
    mgcv::s(anyo, k = 10) +
    caladero,
  data = datos_modelo,
  method = "REML"
)

cli::cli_alert_success("Modelo GAM de peso ajustado correctamente.")

###############################################################################
# Persistencia de modelos y diagnóstico gráfico
###############################################################################

cli::cli_h1("Persistencia de modelos y productos gráficos")

dir_modelos <- here::here("resultados", "modelos")
if (!dir.exists(dir_modelos)) {
  dir.create(dir_modelos, recursive = TRUE)
}

ruta_modelo_gam <- file.path(dir_modelos, "modelo_gam_peso.rds")
saveRDS(modelo_gam_peso, ruta_modelo_gam)

cli::cli_alert_success(paste0(
  "Modelo GAM guardado en: ", ruta_modelo_gam
))

cli::cli_alert_info("Generando predicciones suavizadas para visualización.")

nuevo_grid <- datos_modelo |>
  dplyr::group_by(caladero) |>
  dplyr::summarise(
    longitud = seq(
      from = quantile(longitud, 0.05),
      to   = quantile(longitud, 0.95),
      length.out = 100
    ),
    anyo = median(anyo, na.rm = TRUE),
    .groups = "drop"
  )

predicciones <- dplyr::bind_cols(
  nuevo_grid,
  tibble::tibble(
    peso_pred = stats::predict(modelo_gam_peso, newdata = nuevo_grid, type = "response")
  )
)

dir_resultados <- here::here("resultados")
if (!dir.exists(dir_resultados)) {
  dir.create(dir_resultados, recursive = TRUE)
}

grafico_gam <- ggplot2::ggplot(
  predicciones,
  ggplot2::aes(x = longitud, y = peso_pred, colour = caladero)
) +
  ggplot2::geom_line(linewidth = 1) +
  ggplot2::labs(
    title = "Relación suavizada peso–longitud por caladero (GAM RAP ICES)",
    x = "Longitud (cm)",
    y = "Peso esperado (g)",
    colour = "Caladero"
  ) +
  ggplot2::theme_minimal()

ruta_grafico <- file.path(dir_resultados, "GAM_peso_longitud_por_caladero.png")
ggplot2::ggsave(
  filename = ruta_grafico,
  plot = grafico_gam,
  width = 8,
  height = 5,
  dpi = 300
)

cli::cli_alert_success(paste0(
  "Gráfico GAM guardado en: ", ruta_grafico
))

cli::cli_h1("Fin del Script 03 – Modelización GAM RAP ICES")
