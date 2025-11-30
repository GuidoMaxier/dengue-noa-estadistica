# R/01_diagnostico_datos.R
# ==============================================================================
# DIAGNÓSTICO COMPLETO DEL DATASET DENGUE 2018-2025
# ==============================================================================

source("00_configuracion.R")

cat("=== DIAGNÓSTICO COMPLETO DEL DATASET ===\n")

# 1. CARGA DE DATOS -----------------------------------------------------------
cat("1. CARGANDO DATOS...\n")
dengue_raw <- read_excel("data/raw/dengue_2018_2025.xlsx")

# Mostrar nombres reales de columnas
cat("• Nombres reales de columnas:\n")
cat(paste("  -", names(dengue_raw), collapse = "\n"), "\n")

# 2. INSPECCIÓN INICIAL -------------------------------------------------------
cat("\n2. ESTRUCTURA BÁSICA:\n")
cat("• Dimensiones:", dim(dengue_raw), "(filas x columnas)\n")
cat("• Memoria aprox.:", format(object.size(dengue_raw), units = "MB"), "\n")

# 3. ANÁLISIS POR VARIABLE ----------------------------------------------------
cat("\n3. ANÁLISIS POR VARIABLE:\n")

# Años
cat("• Años:", paste(sort(unique(dengue_raw$anio)), collapse = ", "), "\n")
cat("• Rango años:", min(dengue_raw$anio, na.rm = TRUE), "-", 
    max(dengue_raw$anio, na.rm = TRUE), "\n")

# Provincias (usando el nombre correcto: provincia)
provincias <- unique(dengue_raw$provincia)
cat("• Provincias (", length(provincias), "):", paste(provincias, collapse = ", "), "\n")

# Semanas epidemiológicas
cat("• Rango semanas:", range(dengue_raw$semanas_epidemiologicas, na.rm = TRUE), "\n")

# Grupos etarios (usando el nombre correcto: grupo_edad)
if("grupo_edad" %in% names(dengue_raw)) {
  cat("• Grupos etarios:", paste(unique(dengue_raw$grupo_edad), collapse = ", "), "\n")
}

# 4. CALIDAD DE DATOS ---------------------------------------------------------
cat("\n4. CALIDAD DE DATOS:\n")

# Valores missing
missing_data <- colSums(is.na(dengue_raw))
cat("• Valores missing por columna:\n")
for(col in names(missing_data)) {
  if(missing_data[col] > 0) {
    cat("  -", col, ":", missing_data[col], "NAs (", 
        round(missing_data[col]/nrow(dengue_raw)*100, 1), "%)\n")
  }
}

# Casos cero o negativos
casos_cero <- sum(dengue_raw$cantidad_casos == 0, na.rm = TRUE)
casos_neg <- sum(dengue_raw$cantidad_casos < 0, na.rm = TRUE)
cat("• Casos igual a 0:", casos_cero, "\n")
cat("• Casos negativos:", casos_neg, "\n")

# 5. ESTADÍSTICOS DESCRIPTIVOS ------------------------------------------------
cat("\n5. ESTADÍSTICOS DESCRIPTIVOS:\n")

# Resumen de cantidad_casos
cat("• Resumen de cantidad_casos:\n")
print(summary(dengue_raw$cantidad_casos))

# Total casos por año
cat("\n• Total casos por año:\n")
casos_anio <- dengue_raw %>%
  group_by(anio) %>%
  summarise(total_casos = sum(cantidad_casos, na.rm = TRUE),
            registros = n())
print(casos_anio)

# Total casos por provincia (usando nombre correcto)
cat("\n• Total casos por provincia:\n")
casos_provincia <- dengue_raw %>%
  group_by(provincia) %>%
  summarise(total_casos = sum(cantidad_casos, na.rm = TRUE)) %>%
  arrange(desc(total_casos))
print(casos_provincia)

# Total casos por departamento
cat("\n• Total casos por departamento (top 10):\n")
casos_departamento <- dengue_raw %>%
  group_by(departamento) %>%
  summarise(total_casos = sum(cantidad_casos, na.rm = TRUE)) %>%
  arrange(desc(total_casos)) %>%
  head(10)
print(casos_departamento)

# 6. DETECCIÓN DE ANOMALÍAS ---------------------------------------------------
cat("\n6. DETECCIÓN DE ANOMALÍAS:\n")

# Valores extremos en cantidad_casos
if("cantidad_casos" %in% names(dengue_raw)) {
  q99 <- quantile(dengue_raw$cantidad_casos, 0.99, na.rm = TRUE)
  extremos <- dengue_raw %>% 
    filter(cantidad_casos > q99) %>%
    nrow()
  cat("• Registros > percentil 99:", extremos, "\n")
  
  # Mostrar los valores más altos
  cat("• Top 5 valores más altos:\n")
  print(sort(unique(dengue_raw$cantidad_casos), decreasing = TRUE)[1:5])
}

# 7. ANÁLISIS DE EVENTOS ------------------------------------------------------
if("evento" %in% names(dengue_raw)) {
  cat("\n7. DISTRIBUCIÓN DE EVENTOS:\n")
  eventos <- dengue_raw %>%
    count(evento, sort = TRUE)
  print(eventos)
}

# 8. GUARDAR DATOS Y REPORTE -------------------------------------------------
cat("\n8. GUARDANDO RESULTADOS...\n")

save(dengue_raw, file = "data/processed/dengue_raw.RData")

# Reporte detallado
sink("outputs/reportes/diagnostico_completo.txt")
cat("REPORTE DE DIAGNÓSTICO - DATASET DENGUE NOA\n")
cat("============================================\n")
cat("Fecha análisis:", format(Sys.Date(), "%Y-%m-%d"), "\n\n")

cat("DIMENSIONES:", nrow(dengue_raw), "filas x", ncol(dengue_raw), "columnas\n\n")

cat("VARIABLES DISPONIBLES:\n")
cat(paste("-", names(dengue_raw), collapse = "\n"))
cat("\n\nDISTRIBUCIÓN POR AÑO:\n")
print(table(dengue_raw$anio))

cat("\nPROVINCIAS INCLUIDAS:\n")
cat(paste("-", unique(dengue_raw$provincia), collapse = "\n"))

cat("\n\nTOTAL CASOS POR AÑO:\n")
print(casos_anio)

cat("\nTOTAL CASOS POR PROVINCIA:\n")
print(casos_provincia)

cat("\nCALIDAD DE DATOS - VALORES MISSING:\n")
print(missing_data[missing_data > 0])
sink()

cat("✅ Diagnóstico completado\n")
cat("💾 Datos guardados en: data/processed/dengue_raw.RData\n")
cat("📄 Reporte en: outputs/reportes/diagnostico_completo.txt\n")