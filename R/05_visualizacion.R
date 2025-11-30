# R/05_visualizacion.R
# ==============================================================================
# VISUALIZACIONES AVANZADAS Y REPORTES FINALES - DENGUE NOA
# ==============================================================================

source("00_configuracion.R")
load("data/processed/dengue_clean.RData")
load("data/processed/resultados_descriptivos.RData")
load("data/processed/resultados_inferenciales.RData")

cat("=== GENERANDO VISUALIZACIONES AVANZADAS - DENGUE NOA ===\n")

# 1. SERIES TEMPORALES AVANZADAS ----------------------------------------------
cat("1. CREANDO SERIES TEMPORALES AVANZADAS...\n")

# Serie temporal por provincia con suavizado
p_series_provincia <- dengue_clean %>%
  group_by(anio, provincia) %>%
  summarise(total_casos = sum(cantidad_casos), .groups = 'drop') %>%
  ggplot(aes(x = anio, y = total_casos, color = provincia)) +
  geom_line(size = 1.2, alpha = 0.8) +
  geom_point(size = 2.5) +
  geom_smooth(method = "loess", se = FALSE, size = 0.8, linetype = "dashed") +
  labs(title = "Evolución Temporal de Casos de Dengue por Provincia - NOA",
       subtitle = "Período 2018-2025 con tendencias suavizadas",
       x = "Año", y = "Total de Casos", color = "Provincia") +
  theme_minimal() +
  scale_color_brewer(palette = "Set2") +
  scale_y_continuous(labels = scales::comma) +
  theme(legend.position = "bottom")

ggsave("outputs/figuras/01_series_temporales/series_temporales_provincias.png", 
       p_series_provincia, width = 14, height = 8, dpi = 300)

# 2. ANÁLISIS DE PANDEMIA DETALLADO -------------------------------------------
cat("2. VISUALIZANDO IMPACTO DE PANDEMIA...\n")

# Heatmap de casos por año y provincia
p_heatmap <- dengue_clean %>%
  group_by(anio, provincia) %>%
  summarise(total_casos = sum(cantidad_casos), .groups = 'drop') %>%
  ggplot(aes(x = factor(anio), y = provincia, fill = total_casos)) +
  geom_tile(color = "white", size = 0.5) +
  geom_text(aes(label = format(total_casos, big.mark = ".")), color = "white", size = 3) +
  scale_fill_viridis_c(trans = "log10", labels = scales::comma, 
                       name = "Total Casos (log10)") +
  labs(title = "Heatmap: Distribución de Casos de Dengue por Año y Provincia - NOA",
       x = "Año", y = "Provincia") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("outputs/figuras/04_analisis_pandemia/heatmap_casos_provincia_anio.png",
       p_heatmap, width = 12, height = 6, dpi = 300)

# 3. DISTRIBUCIÓN ESTACIONAL DETALLADA ----------------------------------------
cat("3. ANALIZANDO ESTACIONALIDAD...\n")

# Casos por semana epidemiológica
p_estacionalidad <- dengue_clean %>%
  group_by(semanas_epidemiologicas) %>%
  summarise(total_casos = sum(cantidad_casos), .groups = 'drop') %>%
  ggplot(aes(x = semanas_epidemiologicas, y = total_casos)) +
  geom_area(fill = "steelblue", alpha = 0.7) +
  geom_line(color = "darkblue", size = 1) +
  labs(title = "Patrón Estacional de Dengue en NOA por Semana Epidemiológica",
       subtitle = "Acumulado 2018-2025",
       x = "Semana Epidemiológica", y = "Total de Casos") +
  theme_minimal() +
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(breaks = seq(1, 53, 4)) +
  annotate("rect", xmin = 1, xmax = 13, ymin = 0, ymax = Inf, 
           alpha = 0.2, fill = "red") +
  annotate("rect", xmin = 14, xmax = 26, ymin = 0, ymax = Inf, 
           alpha = 0.2, fill = "orange") +
  annotate("text", x = 7, y = max(dengue_clean %>% 
                                    group_by(semanas_epidemiologicas) %>% 
                                    summarise(total = sum(cantidad_casos)) %>% 
                                    pull(total)) * 0.9, 
           label = "T1 (Ene-Mar)", color = "red", fontface = "bold") +
  annotate("text", x = 20, y = max(dengue_clean %>% 
                                     group_by(semanas_epidemiologicas) %>% 
                                     summarise(total = sum(cantidad_casos)) %>% 
                                     pull(total)) * 0.9, 
           label = "T2 (Abr-Jun)", color = "orange", fontface = "bold")

ggsave("outputs/figuras/01_series_temporales/estacionalidad_semanal.png",
       p_estacionalidad, width = 14, height = 7, dpi = 300)

# 4. ANÁLISIS DE GRUPOS ETARIOS DETALLADO -------------------------------------
cat("4. VISUALIZANDO DISTRIBUCIÓN ETARIA AVANZADA...\n")

# Pirámide poblacional de casos
p_piramide <- dengue_clean %>%
  mutate(
    # Simplificar grupos etarios para pirámide
    grupo_piramide = case_when(
      str_detect(grupo_edad_agrupado, "0-9") ~ "0-9",
      str_detect(grupo_edad_agrupado, "10-19") ~ "10-19", 
      str_detect(grupo_edad_agrupado, "20-39") ~ "20-39",
      str_detect(grupo_edad_agrupado, "40-59") ~ "40-59",
      str_detect(grupo_edad_agrupado, "60\\+") ~ "60+",
      TRUE ~ "Otros"
    )
  ) %>%
  group_by(grupo_piramide) %>%
  summarise(total_casos = sum(cantidad_casos), .groups = 'drop') %>%
  ggplot(aes(x = grupo_piramide, y = total_casos)) +
  geom_col(fill = "coral", alpha = 0.8) +
  geom_text(aes(label = format(total_casos, big.mark = ".")), 
            vjust = -0.5, size = 3, fontface = "bold") +
  labs(title = "Distribución de Casos por Grupo Etario - NOA 2018-2025",
       x = "Grupo Etario", y = "Total de Casos") +
  theme_minimal() +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.1))) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("outputs/figuras/03_grupos_etarios/piramide_etaria.png",
       p_piramide, width = 10, height = 7, dpi = 300)

# 5. VISUALIZACIÓN DE RESULTADOS DE MODELOS -----------------------------------
cat("5. VISUALIZANDO RESULTADOS DE MODELOS...\n")

# Gráfico de coeficientes del modelo
p_coeficientes <- coeficientes %>%
  filter(term != "(Intercept)") %>%
  mutate(
    term = str_remove(term, "provincia"),
    term = factor(term, levels = term[order(estimate)])
  ) %>%
  ggplot(aes(x = estimate, y = term)) +
  geom_point(size = 3, color = "steelblue") +
  geom_errorbarh(aes(xmin = estimate - std.error, xmax = estimate + std.error), 
                 height = 0.2, color = "steelblue") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Coeficientes del Modelo de Regresión - Impacto en Casos de Dengue",
       subtitle = "Puntos: estimaciones, Barras: error estándar",
       x = "Coeficiente (Impacto en número de casos)", y = "Variable") +
  theme_minimal()

ggsave("outputs/figuras/04_analisis_pandemia/coeficientes_modelo.png",
       p_coeficientes, width = 12, height = 6, dpi = 300)

# 6. MAPA DE CALOR TEMPORAL ---------------------------------------------------
cat("6. CREANDO MAPA DE CALOR TEMPORAL...\n")

# Heatmap de casos por año y mes (aproximado por trimestre)
p_heatmap_temporal <- dengue_clean %>%
  group_by(anio, trimestre_epidemio) %>%
  summarise(total_casos = sum(cantidad_casos), .groups = 'drop') %>%
  ggplot(aes(x = factor(anio), y = trimestre_epidemio, fill = total_casos)) +
  geom_tile(color = "white", size = 0.8) +
  geom_text(aes(label = format(total_casos, big.mark = ".")), 
            color = "white", size = 3, fontface = "bold") +
  scale_fill_viridis_c(trans = "log10", labels = scales::comma,
                       name = "Total Casos\n(log10)") +
  labs(title = "Distribución Temporal de Casos de Dengue - NOA",
       subtitle = "Casos por año y trimestre epidemiológico",
       x = "Año", y = "Trimestre Epidemiológico") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("outputs/figuras/01_series_temporales/heatmap_temporal_trimestral.png",
       p_heatmap_temporal, width = 12, height = 6, dpi = 300)

# 7. REPORTE FINAL EJECUTIVO --------------------------------------------------
cat("7. GENERANDO REPORTE FINAL EJECUTIVO...\n")

sink("outputs/reportes/resumen_ejecutivo_final.txt")
cat("RESUMEN EJECUTIVO - ANÁLISIS EPIDEMIOLÓGICO DENGUE NOA 2018-2025\n")
cat("================================================================\n")
cat("Fecha del análisis:", format(Sys.Date(), "%d/%m/%Y"), "\n\n")

cat("HALLazGOS PRINCIPALES:\n\n")

# Totales y tendencia
cat("1. CARGA DE ENFERMEDAD:\n")
cat("   • Total de casos en NOA (2018-2025):", format(sum(dengue_clean$cantidad_casos), big.mark = "."), "\n")
cat("   • Año pico: 2024 con", format(163030, big.mark = "."), "casos (67.2% del total)\n")
cat("   • Tendencia: Crecimiento exponencial a partir de 2023\n\n")

# Distribución geográfica
cat("2. DISTRIBUCIÓN GEOGRÁFICA:\n")
cat("   • Provincia más afectada: Tucumán (45.0% del total)\n")
cat("   • Otras provincias críticas: Salta (19.1%), Santiago del Estero (14.4%)\n")
cat("   • Distribución heterogénea con focos epidémicos definidos\n\n")

# Patrón temporal
cat("3. PATRÓN TEMPORAL Y ESTACIONALIDAD:\n")
cat("   • Estacionalidad marcada: 99.7% de casos entre enero y junio\n")
cat("   • Período de mayor incidencia: Trimestre 2 (Abril-Junio) - 55.6%\n")
cat("   • Baja incidencia en segundo semestre\n\n")

# Grupos de riesgo
cat("4. GRUPOS ETARIOS AFECTADOS:\n")
cat("   • Población adulta: 45-65 años (19.7%), 25-34 años (18.3%)\n")
cat("   • Menor afectación en menores de 10 años\n")
cat("   • Distribución similar a patrones epidemiológicos conocidos\n\n")

# Impacto pandemia
cat("5. IMPACTO DE LA PANDEMIA COVID-19:\n")
cat("   • Período pandémico (2020-2021): 13,580 casos (5.6% del total)\n")
cat("   • Post-pandemia: Brote explosivo en 2023-2024\n")
cat("   • Posible efecto de inmunidad colectiva y factores ambientales\n\n")

cat("CONCLUSIONES Y RECOMENDACIONES:\n")
cat("• Se evidencia una epidemia de dengue de magnitud creciente en NOA\n")
cat("• Tucumán requiere atención prioritaria en estrategias de control\n")
cat("• La estacionalidad marcada sugiere optimizar timing de intervenciones\n")
cat("• Grupos adultos representan la mayor carga de enfermedad\n")
cat("• Necesidad de fortalecer vigilancia epidemiológica y control vectorial\n")
cat("• Considerar factores climáticos y ambientales en modelos predictivos\n\n")

cat("METODOLOGÍA:\n")
cat("• Análisis de 24,271 registros de casos confirmados 2018-2025\n")
cat("• Estadística descriptiva e inferencial con R\n")
cat("• Modelos de regresión lineal múltiple\n")
cat("• Validación de supuestos estadísticos\n")
sink()

# 8. CREAR SCRIPT DE ENTREGA FINAL --------------------------------------------
cat("8. PREPARANDO SCRIPT DE ENTREGA...\n")

script_entrega <- '
# SCRIPT DE ENTREGA FINAL - ANÁLISIS DENGUE NOA
# =============================================
# Para ejecutar el análisis completo en orden:

# 1. Configuración inicial
source("00_configuracion.R")

# 2. Diagnóstico de datos
source("R/01_diagnostico_datos.R")

# 3. Limpieza y preprocesamiento
source("R/02_limpieza_preprocesamiento.R")

# 4. Análisis descriptivo
source("R/03_analisis_descriptivo.R")

# 5. Análisis inferencial
source("R/04_analisis_inferencial.R")

# 6. Visualizaciones avanzadas
source("R/05_visualizacion.R")

cat(" ANÁLISIS COMPLETADO EXITOSAMENTE \\n")
cat(" ENTREGABLES GENERADOS:\\n")
cat("   • data/processed/dengue_clean.RData\\n")
cat("   • outputs/figuras/ [15+ visualizaciones]\\n")
cat("   • outputs/reportes/ [5+ reportes analíticos]\\n")
cat("   • outputs/tablas/ [tablas de resultados]\\n")
'

writeLines(script_entrega, "ejecutar_analisis_completo.R")

cat("Visualizaciones y reportes finales completados\n")
cat(" 15+ gráficos guardados en outputs/figuras/\n")
cat(" Reporte ejecutivo en: outputs/reportes/resumen_ejecutivo_final.txt\n")
cat(" Script de entrega: ejecutar_analisis_completo.R\n")
cat(" PROYECTO TERMINADO - LISTO PARA ENTREGA \n")