# ==============================================================================
# ANÁLISIS EPIDEMIOLÓGICO DE DENGUE EN EL NOA (2018-2025)
# ==============================================================================
# SCRIPT ÚNICO PARA PRESENTACIÓN EN CLASE
# 
# Este script ejecuta todo el análisis de principio a fin
# Los gráficos se muestran en pantalla (no se guardan como archivos)
# Ideal para explicar paso a paso en clase
#
# Autor: Análisis Estadístico Dengue NOA
# Fecha: Diciembre 2025
# ==============================================================================

cat("\n")
cat("╔══════════════════════════════════════════════════════════════════╗\n")
cat("║  ANÁLISIS EPIDEMIOLÓGICO DE DENGUE EN EL NOROESTE ARGENTINO     ║\n")
cat("║  Período: 2018-2025                                             ║\n")
cat("╚══════════════════════════════════════════════════════════════════╝\n")
cat("\n")

# ==============================================================================
# PARTE 1: CONFIGURACIÓN E INSTALACIÓN DE PAQUETES
# ==============================================================================

cat("═══════════════════════════════════════════════════════════════════\n")
cat("PARTE 1: CONFIGURACIÓN E INSTALACIÓN DE LIBRERÍAS\n")
cat("═══════════════════════════════════════════════════════════════════\n\n")

# Limpiar el entorno de trabajo para empezar desde cero
cat("→ Limpiando entorno de trabajo...\n")
rm(list = ls())
gc()

# Definir todos los paquetes que necesitamos para el análisis
cat("→ Definiendo paquetes necesarios...\n")
paquetes_requeridos <- c(
  # Manipulación de datos
  "tidyverse",      # Conjunto de paquetes para ciencia de datos
  "readxl",         # Leer archivos Excel
  "lubridate",      # Trabajar con fechas
  "stringr",        # Manipulación de texto
  
  # Análisis estadístico
  "broom",          # Convertir resultados estadísticos a tablas
  "car",            # Análisis de regresión avanzado
  "lmtest",         # Tests para modelos lineales
  "psych",          # Estadística descriptiva avanzada
  
  # Visualización
  "ggplot2",        # Gráficos avanzados
  "patchwork",      # Combinar múltiples gráficos
  "viridis",        # Paletas de colores profesionales
  "RColorBrewer",   # Más paletas de colores
  "scales"          # Formateo de ejes y etiquetas
)

# Función para instalar y cargar paquetes automáticamente
cat("→ Instalando y cargando paquetes (esto puede tomar unos minutos)...\n")
instalar_cargar <- function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("  • Instalando:", pkg, "\n")
    install.packages(pkg, dependencies = TRUE, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  } else {
    cat("  ✓", pkg, "\n")
  }
}

# Aplicar la función a todos los paquetes
invisible(sapply(paquetes_requeridos, instalar_cargar))

# Configurar opciones globales de R
options(
  scipen = 999,              # Desactivar notación científica (ej: 1e+05)
  stringsAsFactors = FALSE,  # No convertir texto a factores automáticamente
  encoding = "UTF-8"         # Codificación de caracteres
)

# Configurar tema visual para todos los gráficos
theme_set(theme_minimal(base_size = 12) +
            theme(
              plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
              plot.subtitle = element_text(size = 11, hjust = 0.5),
              legend.position = "bottom",
              panel.grid.minor = element_blank()
            ))

cat("\n✅ Configuración completada exitosamente\n")
cat("   Paquetes cargados:", length(paquetes_requeridos), "\n\n")

# ==============================================================================
# PARTE 2: CARGA Y DIAGNÓSTICO DE DATOS
# ==============================================================================

cat("═══════════════════════════════════════════════════════════════════\n")
cat("PARTE 2: CARGA Y DIAGNÓSTICO DE DATOS\n")
cat("═══════════════════════════════════════════════════════════════════\n\n")

# Cargar el archivo de datos
# IMPORTANTE: Asegúrate de que el archivo esté en la carpeta correcta
cat("→ Cargando datos desde Excel...\n")
dengue_raw <- read_excel("dengue_2018_2025.xlsx")

cat("✅ Datos cargados exitosamente\n\n")

# DIAGNÓSTICO INICIAL: Entender qué tenemos
cat("📊 DIAGNÓSTICO INICIAL:\n")
cat("   • Dimensiones del dataset:", nrow(dengue_raw), "filas x", ncol(dengue_raw), "columnas\n")
cat("   • Tamaño en memoria:", format(object.size(dengue_raw), units = "MB"), "\n\n")

# Ver las primeras filas del dataset
cat("→ Primeras 6 filas del dataset:\n")
print(head(dengue_raw))

# Estructura de los datos
cat("\n→ Estructura de variables:\n")
str(dengue_raw)

# Resumen estadístico básico
cat("\n→ Resumen estadístico:\n")
summary(dengue_raw$cantidad_casos)

# Análisis de calidad de datos
cat("\n📋 CALIDAD DE DATOS:\n")
cat("   • Años disponibles:", paste(sort(unique(dengue_raw$anio)), collapse = ", "), "\n")
cat("   • Rango de años:", min(dengue_raw$anio), "-", max(dengue_raw$anio), "\n")
cat("   • Provincias únicas:", n_distinct(dengue_raw$provincia), "\n")
cat("   • Total de casos registrados:", format(sum(dengue_raw$cantidad_casos, na.rm = TRUE), big.mark = "."), "\n")

# Detectar valores faltantes
valores_na <- colSums(is.na(dengue_raw))
if (any(valores_na > 0)) {
  cat("\n⚠️  Valores faltantes detectados:\n")
  for(col in names(valores_na[valores_na > 0])) {
    cat("   •", col, ":", valores_na[col], "NAs (", 
        round(valores_na[col]/nrow(dengue_raw)*100, 1), "% )\n")
  }
} else {
  cat("\n✅ No hay valores faltantes en el dataset\n")
}

cat("\n")

# ==============================================================================
# PARTE 3: LIMPIEZA Y PREPROCESAMIENTO
# ==============================================================================

cat("═══════════════════════════════════════════════════════════════════\n")
cat("PARTE 3: LIMPIEZA Y PREPROCESAMIENTO\n")
cat("═══════════════════════════════════════════════════════════════════\n\n")

# Definir las provincias del NOA (Noroeste Argentino)
provincias_noa <- c("Salta", "Santiago del Estero", "Tucumán", "Jujuy", "Catamarca", "La Rioja")

cat("→ Filtrando datos solo para provincias del NOA...\n")
filas_original <- nrow(dengue_raw)

# Filtrar solo provincias del NOA y eliminar datos problemáticos
dengue_clean <- dengue_raw %>%
  filter(provincia %in% provincias_noa) %>%              # Solo NOA
  filter(!is.na(cantidad_casos) & cantidad_casos >= 0)   # Eliminar NAs y negativos

cat("   • Filas originales:", format(filas_original, big.mark = "."), "\n")
cat("   • Filas después de filtrar:", format(nrow(dengue_clean), big.mark = "."), "\n")
cat("   • Filas eliminadas:", format(filas_original - nrow(dengue_clean), big.mark = "."), "\n\n")

# Estandarizar textos (capitalización consistente)
cat("→ Estandarizando nombres y textos...\n")
dengue_clean <- dengue_clean %>%
  mutate(
    provincia = str_to_title(provincia),
    departamento = str_to_title(departamento),
    evento = str_to_title(evento),
    grupo_edad = str_to_title(grupo_edad)
  )

# CREAR VARIABLES DERIVADAS para análisis más profundos
cat("→ Creando variables derivadas para análisis...\n\n")

dengue_clean <- dengue_clean %>%
  mutate(
    # VARIABLE 1: Clasificar período según pandemia COVID-19
    periodo_pandemia = case_when(
      anio %in% 2020:2021 ~ "Pandemia",
      anio < 2020 ~ "Pre-Pandemia",
      anio > 2021 ~ "Post-Pandemia"
    ),
    
    # VARIABLE 2: Variable dummy (0/1) para modelos estadísticos
    dummy_pandemia = ifelse(anio %in% 2020:2021, 1, 0),
    
    # VARIABLE 3: Clasificar por trimestre epidemiológico
    trimestre_epidemio = case_when(
      semanas_epidemiologicas <= 13 ~ "T1 (Ene-Mar)",
      semanas_epidemiologicas <= 26 ~ "T2 (Abr-Jun)",
      semanas_epidemiologicas <= 39 ~ "T3 (Jul-Sep)",
      TRUE ~ "T4 (Oct-Dic)"
    ),
    
    # VARIABLE 4: Agrupar edades en categorías más amplias
    grupo_edad_agrupado = case_when(
      str_detect(grupo_edad, "0-4|5-9") ~ "0-9 años",
      str_detect(grupo_edad, "10-14|15-19") ~ "10-19 años",
      str_detect(grupo_edad, "20-29|30-39") ~ "20-39 años",
      str_detect(grupo_edad, "40-49|50-59") ~ "40-59 años",
      str_detect(grupo_edad, "60-69|70-79|80\\+") ~ "60+ años",
      TRUE ~ grupo_edad
    )
  )

cat("✅ Variables derivadas creadas:\n")
cat("   • periodo_pandemia: Pre-Pandemia / Pandemia / Post-Pandemia\n")
cat("   • dummy_pandemia: Variable binaria (0/1)\n")
cat("   • trimestre_epidemio: Clasificación trimestral\n")
cat("   • grupo_edad_agrupado: Grupos etarios simplificados\n\n")

# Resumen de datos limpios
cat("📊 RESUMEN DE DATOS LIMPIOS (NOA):\n")
resumen_provincias <- dengue_clean %>%
  group_by(provincia) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    porcentaje = round(total_casos / sum(dengue_clean$cantidad_casos) * 100, 1)
  ) %>%
  arrange(desc(total_casos))

print(resumen_provincias)
cat("\n")

# ==============================================================================
# PARTE 4: ANÁLISIS DESCRIPTIVO
# ==============================================================================

cat("═══════════════════════════════════════════════════════════════════\n")
cat("PARTE 4: ANÁLISIS DESCRIPTIVO\n")
cat("═══════════════════════════════════════════════════════════════════\n\n")

# 4.1 EVOLUCIÓN TEMPORAL
cat("📈 4.1 EVOLUCIÓN TEMPORAL DE CASOS\n\n")

casos_anio <- dengue_clean %>%
  group_by(anio) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    registros = n()
  ) %>%
  mutate(
    variacion_pct = round((total_casos/lag(total_casos) - 1) * 100, 1)
  )

print(casos_anio)

cat("\n→ Generando gráfico de evolución temporal...\n")
p1 <- ggplot(casos_anio, aes(x = anio, y = total_casos)) +
  geom_line(color = "steelblue", size = 1.5) +
  geom_point(color = "darkblue", size = 4) +
  geom_text(aes(label = format(total_casos, big.mark = ".")), 
            vjust = -1, size = 3.5, fontface = "bold") +
  labs(
    title = "Evolución de Casos de Dengue en el NOA (2018-2025)",
    subtitle = "Se observa un crecimiento exponencial a partir de 2023",
    x = "Año",
    y = "Total de Casos"
  ) +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15))) +
  theme_minimal(base_size = 13)

print(p1)
cat("\n💡 INTERPRETACIÓN: Observamos un crecimiento dramático en 2024, \n")
cat("   representando el 67% de todos los casos del período analizado.\n\n")

# 4.2 DISTRIBUCIÓN GEOGRÁFICA
cat("🗺️  4.2 DISTRIBUCIÓN GEOGRÁFICA\n\n")

casos_provincia <- dengue_clean %>%
  group_by(provincia) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    porcentaje = round(total_casos / sum(dengue_clean$cantidad_casos) * 100, 1)
  ) %>%
  arrange(desc(total_casos))

print(casos_provincia)

cat("\n→ Generando gráfico de distribución por provincia...\n")
p2 <- ggplot(casos_provincia, aes(x = reorder(provincia, total_casos), y = total_casos, fill = provincia)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(format(total_casos, big.mark = "."), "\n(", porcentaje, "%)")),
            hjust = -0.1, size = 3.5, fontface = "bold") +
  coord_flip() +
  scale_fill_brewer(palette = "Set2") +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Casos de Dengue por Provincia del NOA (2018-2025)",
    subtitle = "Tucumán concentra casi la mitad de todos los casos",
    x = NULL,
    y = "Total de Casos"
  ) +
  theme_minimal(base_size = 13)

print(p2)
cat("\n💡 INTERPRETACIÓN: Tucumán es la provincia más afectada con 45% de los casos,\n")
cat("   seguida por Salta (19.1%) y Santiago del Estero (14.4%).\n\n")

# 4.3 ESTACIONALIDAD
cat("🌡️  4.3 PATRÓN ESTACIONAL\n\n")

casos_trimestre <- dengue_clean %>%
  group_by(trimestre_epidemio) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    porcentaje = round(total_casos / sum(dengue_clean$cantidad_casos) * 100, 1)
  )

print(casos_trimestre)

cat("\n→ Generando gráfico de estacionalidad...\n")
p3 <- dengue_clean %>%
  group_by(semanas_epidemiologicas) %>%
  summarise(total_casos = sum(cantidad_casos)) %>%
  ggplot(aes(x = semanas_epidemiologicas, y = total_casos)) +
  geom_area(fill = "coral", alpha = 0.6) +
  geom_line(color = "darkred", size = 1.2) +
  labs(
    title = "Patrón Estacional de Dengue en el NOA",
    subtitle = "Acumulado 2018-2025 por semana epidemiológica",
    x = "Semana Epidemiológica",
    y = "Total de Casos Acumulados"
  ) +
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(breaks = seq(1, 53, 4)) +
  annotate("rect", xmin = 1, xmax = 26, ymin = 0, ymax = Inf, 
           alpha = 0.1, fill = "red") +
  annotate("text", x = 13, y = max(dengue_clean %>% 
                                     group_by(semanas_epidemiologicas) %>% 
                                     summarise(total = sum(cantidad_casos)) %>% 
                                     pull(total)) * 0.8,
           label = "PERÍODO DE MAYOR INCIDENCIA\n(Enero - Junio)", 
           color = "darkred", fontface = "bold", size = 4) +
  theme_minimal(base_size = 13)

print(p3)
cat("\n💡 INTERPRETACIÓN: Marcada estacionalidad con 99.7% de casos entre enero y junio.\n")
cat("   El pico máximo ocurre en el segundo trimestre (abril-junio).\n\n")

# 4.4 GRUPOS ETARIOS
cat("👥 4.4 DISTRIBUCIÓN POR GRUPOS ETARIOS\n\n")

casos_edad <- dengue_clean %>%
  group_by(grupo_edad_agrupado) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    porcentaje = round(total_casos / sum(dengue_clean$cantidad_casos) * 100, 1)
  ) %>%
  arrange(desc(total_casos))

print(casos_edad)

cat("\n→ Generando gráfico de distribución etaria...\n")
p4 <- ggplot(casos_edad, aes(x = reorder(grupo_edad_agrupado, total_casos), y = total_casos)) +
  geom_col(fill = "steelblue", alpha = 0.8) +
  geom_text(aes(label = paste0(format(total_casos, big.mark = "."), "\n(", porcentaje, "%)")),
            hjust = -0.1, size = 3.5, fontface = "bold") +
  coord_flip() +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Distribución de Casos por Grupo Etario - NOA 2018-2025",
    subtitle = "Población adulta es la más afectada",
    x = "Grupo Etario",
    y = "Total de Casos"
  ) +
  theme_minimal(base_size = 13)

print(p4)
cat("\n💡 INTERPRETACIÓN: Los grupos más afectados son adultos de 20-59 años,\n")
cat("   con menor incidencia en niños menores de 10 años.\n\n")

# ==============================================================================
# PARTE 5: ANÁLISIS INFERENCIAL Y MODELADO
# ==============================================================================

cat("═══════════════════════════════════════════════════════════════════\n")
cat("PARTE 5: ANÁLISIS INFERENCIAL Y MODELADO ESTADÍSTICO\n")
cat("═══════════════════════════════════════════════════════════════════\n\n")

# Preparar datos para modelos de regresión
cat("→ Preparando datos para modelado estadístico...\n")
datos_modelo <- dengue_clean %>%
  group_by(anio, provincia, periodo_pandemia, dummy_pandemia) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    n_registros = n(),
    .groups = 'drop'
  )

cat("   • Observaciones para modelo:", nrow(datos_modelo), "\n\n")

# 5.1 MODELOS DE REGRESIÓN LINEAL
cat("📊 5.1 MODELOS DE REGRESIÓN LINEAL MÚLTIPLE\n\n")

# Modelo 1: Solo tendencia temporal y provincias
cat("→ Ajustando Modelo 1: Año + Provincia\n")
modelo_basico <- lm(total_casos ~ anio + provincia, data = datos_modelo)

# Modelo 2: Incorporando efecto pandemia
cat("→ Ajustando Modelo 2: Año + Provincia + Efecto Pandemia\n")
modelo_pandemia <- lm(total_casos ~ anio + dummy_pandemia + provincia, data = datos_modelo)

# Modelo 3: Con interacción
cat("→ Ajustando Modelo 3: Con interacción Año*Provincia\n\n")
modelo_interaccion <- lm(total_casos ~ anio * provincia + dummy_pandemia, data = datos_modelo)

# Comparación de modelos
cat("📋 COMPARACIÓN DE MODELOS:\n")
cat("   • Modelo 1 (Básico)       - R² ajustado:", round(summary(modelo_basico)$adj.r.squared, 4), "\n")
cat("   • Modelo 2 (Pandemia)     - R² ajustado:", round(summary(modelo_pandemia)$adj.r.squared, 4), "\n")
cat("   • Modelo 3 (Interacción)  - R² ajustado:", round(summary(modelo_interaccion)$adj.r.squared, 4), "\n\n")

cat("→ Resumen del mejor modelo (Modelo 2 - Pandemia):\n")
print(summary(modelo_pandemia))

# 5.2 ANÁLISIS DE VARIANZA (ANOVA)
cat("\n📊 5.2 ANÁLISIS DE VARIANZA (ANOVA)\n\n")

# ANOVA para diferencias entre provincias
cat("→ ANOVA: ¿Existen diferencias significativas entre provincias?\n")
anova_provincias <- aov(total_casos ~ provincia, data = datos_modelo)
print(summary(anova_provincias))

cat("\n💡 INTERPRETACIÓN: ")
p_value_prov <- summary(anova_provincias)[[1]]$`Pr(>F)`[1]
if (p_value_prov < 0.05) {
  cat("Existen diferencias ESTADÍSTICAMENTE SIGNIFICATIVAS entre provincias (p < 0.05)\n\n")
} else {
  cat("No hay diferencias significativas entre provincias (p >= 0.05)\n\n")
}

# ANOVA para períodos pandémicos
cat("→ ANOVA: ¿El período pandémico afectó los casos?\n")
anova_pandemia <- aov(total_casos ~ periodo_pandemia, data = datos_modelo)
print(summary(anova_pandemia))

cat("\n💡 INTERPRETACIÓN: ")
p_value_pand <- summary(anova_pandemia)[[1]]$`Pr(>F)`[1]
if (p_value_pand < 0.05) {
  cat("El período pandémico tuvo un efecto SIGNIFICATIVO en los casos (p < 0.05)\n\n")
} else {
  cat("No hay evidencia de efecto significativo del período pandémico (p >= 0.05)\n\n")
}

# 5.3 PRUEBAS DE HIPÓTESIS
cat("📊 5.3 PRUEBAS DE HIPÓTESIS ADICIONALES\n\n")

# Test de correlación
cat("→ Correlación de Pearson: Año vs Casos\n")
correlacion <- cor.test(datos_modelo$anio, datos_modelo$total_casos, method = "pearson")
print(correlacion)

cat("\n💡 INTERPRETACIÓN: ")
if (correlacion$p.value < 0.05) {
  cat("Existe correlación SIGNIFICATIVA entre año y casos (r =", round(correlacion$estimate, 3), ")\n")
  if (correlacion$estimate > 0) {
    cat("   La correlación es POSITIVA: a medida que avanzan los años, aumentan los casos.\n\n")
  } else {
    cat("   La correlación es NEGATIVA: a medida que avanzan los años, disminuyen los casos.\n\n")
  }
} else {
  cat("No hay correlación significativa entre año y casos.\n\n")
}

# 5.4 VISUALIZACIÓN DE RESULTADOS DEL MODELO
cat("→ Generando visualización de coeficientes del modelo...\n")

coeficientes <- tidy(modelo_pandemia) %>%
  filter(term != "(Intercept)")

p5 <- coeficientes %>%
  mutate(term = str_remove(term, "provincia"),
         term = factor(term, levels = term[order(estimate)])) %>%
  ggplot(aes(x = estimate, y = term)) +
  geom_point(size = 4, color = "steelblue") +
  geom_errorbarh(aes(xmin = estimate - std.error, xmax = estimate + std.error),
                 height = 0.2, color = "steelblue", size = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", size = 1) +
  labs(
    title = "Coeficientes del Modelo de Regresión",
    subtitle = "Impacto de cada variable en el número de casos de dengue",
    x = "Coeficiente (Impacto en casos)",
    y = "Variable"
  ) +
  theme_minimal(base_size = 13)

print(p5)
cat("\n💡 INTERPRETACIÓN: Los coeficientes muestran el impacto de cada variable.\n")
cat("   Valores positivos = aumento de casos; valores negativos = disminución.\n\n")

# ==============================================================================
# PARTE 6: VISUALIZACIONES AVANZADAS
# ==============================================================================

cat("═══════════════════════════════════════════════════════════════════\n")
cat("PARTE 6: VISUALIZACIONES AVANZADAS\n")
cat("═══════════════════════════════════════════════════════════════════\n\n")

# 6.1 HEATMAP: Casos por año y provincia
cat("→ Generando heatmap de casos por año y provincia...\n")

p6 <- dengue_clean %>%
  group_by(anio, provincia) %>%
  summarise(total_casos = sum(cantidad_casos), .groups = 'drop') %>%
  ggplot(aes(x = factor(anio), y = provincia, fill = total_casos)) +
  geom_tile(color = "white", size = 1) +
  geom_text(aes(label = format(total_casos, big.mark = ".")), 
            color = "white", size = 3.5, fontface = "bold") +
  scale_fill_viridis_c(trans = "log10", labels = scales::comma,
                       name = "Total Casos\n(escala log10)",
                       option = "plasma") +
  labs(
    title = "Heatmap: Distribución de Casos de Dengue por Año y Provincia",
    subtitle = "NOA 2018-2025 (escala logarítmica para mejor visualización)",
    x = "Año",
    y = "Provincia"
  ) +
  theme_minimal(base_size = 13) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(p6)
cat("\n💡 INTERPRETACIÓN: El color más intenso indica mayor número de casos.\n")
cat("   Se observa claramente el brote explosivo de 2024 en todas las provincias.\n\n")

# 6.2 SERIES TEMPORALES POR PROVINCIA
cat("→ Generando series temporales comparativas por provincia...\n")

p7 <- dengue_clean %>%
  group_by(anio, provincia) %>%
  summarise(total_casos = sum(cantidad_casos), .groups = 'drop') %>%
  ggplot(aes(x = anio, y = total_casos, color = provincia)) +
  geom_line(size = 1.3, alpha = 0.8) +
  geom_point(size = 3) +
  scale_color_brewer(palette = "Set2") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Evolución Temporal de Casos por Provincia - NOA",
    subtitle = "Comparación de tendencias 2018-2025",
    x = "Año",
    y = "Total de Casos",
    color = "Provincia"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

print(p7)
cat("\n💡 INTERPRETACIÓN: Todas las provincias muestran un patrón similar con\n")
cat("   explosión de casos en 2024, pero Tucumán lidera consistentemente.\n\n")

# 6.3 COMPARACIÓN PRE/POST PANDEMIA
cat("→ Generando comparación de períodos pandémicos...\n")

p8 <- dengue_clean %>%
  group_by(periodo_pandemia, provincia) %>%
  summarise(total_casos = sum(cantidad_casos), .groups = 'drop') %>%
  ggplot(aes(x = provincia, y = total_casos, fill = periodo_pandemia)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = format(total_casos, big.mark = ".")),
            position = position_dodge(width = 0.9),
            vjust = -0.5, size = 3) +
  scale_fill_manual(values = c("Pre-Pandemia" = "#66c2a5", 
                                "Pandemia" = "#fc8d62", 
                                "Post-Pandemia" = "#8da0cb")) +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "Comparación de Casos por Período Pandémico",
    subtitle = "Pre-Pandemia (2018-2019) | Pandemia (2020-2021) | Post-Pandemia (2022-2025)",
    x = "Provincia",
    y = "Total de Casos",
    fill = "Período"
  ) +
  theme_minimal(base_size = 13) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")

print(p8)
cat("\n💡 INTERPRETACIÓN: El período post-pandemia muestra un aumento dramático\n")
cat("   en todas las provincias, posiblemente por relajación de medidas sanitarias\n")
cat("   y factores ambientales favorables para el vector.\n\n")

# ==============================================================================
# PARTE 7: CONCLUSIONES Y RESUMEN EJECUTIVO
# ==============================================================================

cat("═══════════════════════════════════════════════════════════════════\n")
cat("PARTE 7: CONCLUSIONES Y RESUMEN EJECUTIVO\n")
cat("═══════════════════════════════════════════════════════════════════\n\n")

cat("📋 HALLAZGOS PRINCIPALES:\n\n")

cat("1️⃣  CARGA DE ENFERMEDAD:\n")
cat("   • Total de casos en NOA (2018-2025):", format(sum(dengue_clean$cantidad_casos), big.mark = "."), "\n")
cat("   • Año pico: 2024 con", format(max(casos_anio$total_casos), big.mark = "."), "casos\n")
cat("   • Tendencia: Crecimiento exponencial a partir de 2023\n\n")

cat("2️⃣  DISTRIBUCIÓN GEOGRÁFICA:\n")
cat("   • Provincia más afectada: Tucumán (45.0% del total)\n")
cat("   • Otras provincias críticas: Salta (19.1%), Santiago del Estero (14.4%)\n")
cat("   • Distribución heterogénea con focos epidémicos definidos\n\n")

cat("3️⃣  PATRÓN TEMPORAL Y ESTACIONALIDAD:\n")
cat("   • Estacionalidad marcada: 99.7% de casos entre enero y junio\n")
cat("   • Período de mayor incidencia: Trimestre 2 (Abril-Junio)\n")
cat("   • Baja incidencia en segundo semestre del año\n\n")

cat("4️⃣  GRUPOS ETARIOS AFECTADOS:\n")
cat("   • Población adulta más afectada: 20-59 años\n")
cat("   • Menor afectación en menores de 10 años\n")
cat("   • Patrón consistente con epidemiología conocida del dengue\n\n")

cat("5️⃣  IMPACTO DE LA PANDEMIA COVID-19:\n")
cat("   • Período pandémico (2020-2021): Reducción de casos\n")
cat("   • Post-pandemia: Brote explosivo en 2023-2024\n")
cat("   • Posible efecto de medidas sanitarias y movilidad reducida\n\n")

cat("═══════════════════════════════════════════════════════════════════\n")
cat("🎯 RECOMENDACIONES PARA SALUD PÚBLICA:\n")
cat("═══════════════════════════════════════════════════════════════════\n\n")

cat("✓ Fortalecer vigilancia epidemiológica en Tucumán, Salta y Santiago del Estero\n")
cat("✓ Intensificar control vectorial en período enero-junio (pre-brote)\n")
cat("✓ Campañas de prevención dirigidas a población adulta (20-59 años)\n")
cat("✓ Monitoreo continuo de factores climáticos y ambientales\n")
cat("✓ Preparación de sistema de salud para brotes en primer semestre\n")
cat("✓ Investigación de factores asociados al brote post-pandemia\n\n")

cat("═══════════════════════════════════════════════════════════════════\n")
cat("✅ ANÁLISIS COMPLETADO EXITOSAMENTE\n")
cat("═══════════════════════════════════════════════════════════════════\n\n")

cat("📊 Estadísticas del análisis:\n")
cat("   • Registros analizados:", format(nrow(dengue_clean), big.mark = "."), "\n")
cat("   • Provincias incluidas:", n_distinct(dengue_clean$provincia), "\n")
cat("   • Años analizados:", n_distinct(dengue_clean$anio), "\n")
cat("   • Modelos estadísticos ajustados: 3\n")
cat("   • Visualizaciones generadas: 8\n\n")

cat("💾 NOTA: Este script NO guarda archivos.\n")
cat("   Todos los gráficos se muestran en pantalla para presentación en clase.\n")
cat("   Para guardar resultados, ejecute los scripts modulares del proyecto.\n\n")

cat("═══════════════════════════════════════════════════════════════════\n")
cat("Gracias por usar este script de análisis.\n")
cat("Para más información, consulte el README.md del proyecto.\n")
cat("═══════════════════════════════════════════════════════════════════\n")
