# R/03_analisis_descriptivo.R
# ==============================================================================
# ANÁLISIS DESCRIPTIVO COMPLETO
# ==============================================================================

source("00_configuracion.R")
load("data/processed/dengue_clean.RData")

cat("=== ANÁLISIS DESCRIPTIVO ===\n")

# 1. RESUMEN GENERAL ----------------------------------------------------------
cat("1. GENERANDO RESUMEN GENERAL...\n")

resumen_general <- dengue_clean %>%
  summarise(
    total_casos = sum(cantidad_casos, na.rm = TRUE),
    total_registros = n(),
    años_unicos = n_distinct(anio),
    provincias_unicas = n_distinct(provincia_nombre),
    promedio_casos_por_registro = mean(cantidad_casos, na.rm = TRUE),
    desvio_casos = sd(cantidad_casos, na.rm = TRUE)
  )

print(resumen_general)

# 2. ANÁLISIS TEMPORAL --------------------------------------------------------
cat("\n2. ANÁLISIS TEMPORAL...\n")

# Por año
casos_anio <- dengue_clean %>%
  group_by(anio) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    registros = n(),
    promedio_diario = mean(cantidad_casos)
  ) %>%
  mutate(variacion_anual = (total_casos/lag(total_casos) - 1) * 100)

print(casos_anio)

# Por año y período pandemia
casos_pandemia <- dengue_clean %>%
  group_by(anio, periodo_pandemia) %>%
  summarise(total_casos = sum(cantidad_casos), .groups = 'drop')

print(casos_pandemia)

# 3. ANÁLISIS GEOGRÁFICO ------------------------------------------------------
cat("\n3. ANÁLISIS GEOGRÁFICO...\n")

# Por provincia
casos_provincia <- dengue_clean %>%
  group_by(provincia_nombre) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    porcentaje_total = total_casos / sum(dengue_clean$cantidad_casos) * 100,
    promedio_casos = mean(cantidad_casos)
  ) %>%
  arrange(desc(total_casos))

print(casos_provincia)

# 4. ANÁLISIS POR GRUPOS ETARIOS ----------------------------------------------
if("grupo_edad_agrupado" %in% names(dengue_clean)) {
  cat("\n4. ANÁLISIS POR GRUPOS ETARIOS...\n")
  
  casos_edad <- dengue_clean %>%
    group_by(grupo_edad_agrupado) %>%
    summarise(
      total_casos = sum(cantidad_casos),
      porcentaje = total_casos / sum(dengue_clean$cantidad_casos) * 100
    ) %>%
    arrange(desc(total_casos))
  
  print(casos_edad)
}

# 5. VISUALIZACIONES BÁSICAS --------------------------------------------------
cat("\n5. GENERANDO VISUALIZACIONES...\n")

# Evolución temporal
p_temporal <- ggplot(casos_anio, aes(x = anio, y = total_casos)) +
  geom_line(color = "steelblue", size = 1.5) +
  geom_point(color = "darkblue", size = 3) +
  labs(title = "Evolución de Casos de Dengue en NOA (2018-2025)",
       x = "Año", y = "Total de Casos") +
  theme_minimal()

ggsave("outputs/figuras/01_series_temporales/evolucion_anual.png", p_temporal, 
       width = 10, height = 6, dpi = 300)

# Casos por provincia
p_provincia <- ggplot(casos_provincia, aes(x = reorder(provincia_nombre, total_casos), y = total_casos)) +
  geom_col(fill = "coral") +
  coord_flip() +
  labs(title = "Casos de Dengue por Provincia (2018-2025)",
       x = "Provincia", y = "Total de Casos") +
  theme_minimal()

ggsave("outputs/figuras/02_distribucion_geografica/casos_por_provincia.png", p_provincia,
       width = 10, height = 6, dpi = 300)

# 6. GUARDAR RESULTADOS -------------------------------------------------------
cat("6. GUARDANDO RESULTADOS...\n")

save(resumen_general, casos_anio, casos_provincia, casos_pandemia,
     file = "data/processed/resultados_descriptivos.RData")

write_csv(casos_anio, "outputs/tablas/casos_por_anio.csv")
write_csv(casos_provincia, "outputs/tablas/casos_por_provincia.csv")

if(exists("casos_edad")) {
  write_csv(casos_edad, "outputs/tablas/casos_por_edad.csv")
}

# Reporte descriptivo
sink("outputs/reportes/resumen_descriptivo.txt")
cat("RESUMEN DESCRIPTIVO - ANÁLISIS DENGUE NOA\n")
cat("==========================================\n")
cat("Fecha:", format(Sys.Date(), "%Y-%m-%d"), "\n\n")

cat("RESUMEN GENERAL:\n")
print(resumen_general)

cat("\nEVOLUCIÓN ANUAL:\n")
print(casos_anio)

cat("\nDISTRIBUCIÓN POR PROVINCIA:\n")
print(casos_provincia)

if(exists("casos_edad")) {
  cat("\nDISTRIBUCIÓN POR EDAD:\n")
  print(casos_edad)
}
sink()

cat("Análisis descriptivo completado\n")
cat("Resultados guardados en data/processed/resultados_descriptivos.RData\n")