# 00_configuracion.R
# ==============================================================================
# PROYECTO ANÁLISIS DENGUE NOA - CONFIGURACIÓN INICIAL
# ==============================================================================

cat("=== INICIANDO PROYECTO ANÁLISIS DENGUE NOA ===\n")

# 1. LIMPIAR ENTORNO ----------------------------------------------------------
rm(list = ls())
gc()

# 2. DEFINIR PAQUETES REQUERIDOS ----------------------------------------------
paquetes_requeridos <- c(
  "tidyverse", "readxl", "openxlsx", "lubridate", "stringr",
  "broom", "car", "lmtest", "nortest", "forecast", "psych",
  "ggplot2", "plotly", "patchwork", "ggthemes", "viridis", "RColorBrewer",
  "knitr", "kableExtra", "rmarkdown",
  "sf", "maps", "rnaturalearth", "ggspatial"
)

# 3. FUNCIÓN PARA INSTALAR/CARGAR ---------------------------------------------
instalar_cargar <- function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

# 4. INSTALAR Y CARGAR TODOS LOS PAQUETES -------------------------------------
cat("Instalando/cargando paquetes...\n")
invisible(sapply(paquetes_requeridos, instalar_cargar))

# 5. CONFIGURAR OPCIONES ------------------------------------------------------
options(
  scipen = 999,           # Desactivar notación científica
  stringsAsFactors = FALSE,
  encoding = "UTF-8",
  warn = -1               # Silenciar warnings temporalmente
)

# 6. CONFIGURAR TEMA GGPLOT2 --------------------------------------------------
if ("ggplot2" %in% paquetes_requeridos) {
  theme_set(theme_minimal(base_size = 12) +
              theme(plot.title = element_text(face = "bold", size = 14),
                    legend.position = "bottom"))
}

# 7. CREAR ESTRUCTURA DE CARPETAS ---------------------------------------------
dirs <- c(
  "data/raw",
  "data/processed", 
  "data/external",
  "R",
  "notebooks",
  "outputs/figuras/01_series_temporales",
  "outputs/figuras/02_distribucion_geografica",
  "outputs/figuras/03_grupos_etarios",
  "outputs/figuras/04_analisis_pandemia",
  "outputs/tablas",
  "outputs/reportes",
  "docs"
)

cat("Creando estructura de carpetas...\n")
sapply(dirs, function(x) if(!dir.exists(x)) dir.create(x, recursive = TRUE))

# 8. MENSAJE FINAL ------------------------------------------------------------
cat("configuración completada\n")
cat("Paquetes cargados:", length(paquetes_requeridos), "\n")
cat("Estructura de carpetas creada\n")
cat("Proyecto listo para análisis\n")
