# R/02_limpieza_preprocesamiento.R
# ==============================================================================
# LIMPIEZA Y PREPROCESAMIENTO DE DATOS
# ==============================================================================

source("00_configuracion.R")
load("data/processed/dengue_raw.RData")

cat("=== LIMPIEZA Y PREPROCESAMIENTO ===\n")

# 1. DEFINIR PROVINCIAS DEL NOA -----------------------------------------------
provincias_noa <- c("Salta", "Santiago del Estero", "Tucumán", "Jujuy", "Catamarca", "La Rioja")

# 2. FILTRAR SOLO PROVINCIAS DEL NOA ------------------------------------------
cat("1. FILTRANDO PROVINCIAS DEL NOA...\n")
filas_original <- nrow(dengue_raw)

dengue_clean <- dengue_raw %>%
  filter(provincia %in% provincias_noa)

cat("• Filas originales:", filas_original, "\n")
cat("• Filas después de filtrar NOA:", nrow(dengue_clean), "\n")
cat("• Filas eliminadas:", filas_original - nrow(dengue_clean), "\n")
cat("• Provincias NOA incluidas:", paste(unique(dengue_clean$provincia), collapse = ", "), "\n")

# 3. LIMPIEZA BÁSICA ----------------------------------------------------------
cat("2. APLICANDO LIMPIEZA BÁSICA...\n")

# Eliminar filas con cantidad_casos missing o negativos
filas_antes_limpieza <- nrow(dengue_clean)
dengue_clean <- dengue_clean %>%
  filter(!is.na(cantidad_casos) & cantidad_casos >= 0)

cat("• Filas eliminadas (NA/negativos):", filas_antes_limpieza - nrow(dengue_clean), "\n")

# 4. ESTANDARIZAR TEXTOS ------------------------------------------------------
cat("3. ESTANDARIZANDO TEXTOS...\n")

dengue_clean <- dengue_clean %>%
  mutate(
    provincia = str_to_title(provincia),
    departamento = str_to_title(departamento),
    evento = str_to_title(evento),
    grupo_edad = str_to_title(grupo_edad)
  )

# 5. CREAR VARIABLES DERIVADAS ------------------------------------------------
cat("4. CREANDO VARIABLES DERIVADAS...\n")

dengue_clean <- dengue_clean %>%
  mutate(
    # Variable período pandemia
    periodo_pandemia = case_when(
      anio %in% 2020:2021 ~ "Pandemia",
      anio < 2020 ~ "Pre-Pandemia", 
      anio > 2021 ~ "Post-Pandemia"
    ),
    # Variable dummy para modelos
    dummy_pandemia = ifelse(anio %in% 2020:2021, 1, 0),
    # Estacionalidad (trimestres epidemiológicos)
    trimestre_epidemio = case_when(
      semanas_epidemiologicas <= 13 ~ "T1 (Ene-Mar)",
      semanas_epidemiologicas <= 26 ~ "T2 (Abr-Jun)",
      semanas_epidemiologicas <= 39 ~ "T3 (Jul-Sep)",
      TRUE ~ "T4 (Oct-Dic)"
    ),
    # Variable temporal continua
    tiempo_continuo = anio + (semanas_epidemiologicas - 1) / 52
  )

# 6. AGRUPAR EDADES -----------------------------------------------------------
cat("5. AGRUPANDO GRUPOS ETARIOS...\n")

dengue_clean <- dengue_clean %>%
  mutate(
    grupo_edad_agrupado = case_when(
      str_detect(grupo_edad, "0-4|5-9") ~ "0-9 años",
      str_detect(grupo_edad, "10-14|15-19") ~ "10-19 años", 
      str_detect(grupo_edad, "20-29|30-39") ~ "20-39 años",
      str_detect(grupo_edad, "40-49|50-59") ~ "40-59 años",
      str_detect(grupo_edad, "60-69|70-79|80\\+") ~ "60+ años",
      TRUE ~ grupo_edad  # Mantener original si no coincide
    )
  )

# 7. VERIFICAR RESULTADO ------------------------------------------------------
cat("6. VERIFICANDO RESULTADOS...\n")

cat("• Dimensiones finales:", dim(dengue_clean), "\n")
cat("• Años en NOA:", paste(sort(unique(dengue_clean$anio)), collapse = ", "), "\n")
cat("• Provincias NOA:", paste(unique(dengue_clean$provincia), collapse = ", "), "\n")
cat("• Períodos:", paste(unique(dengue_clean$periodo_pandemia), collapse = ", "), "\n")
cat("• Grupos etarios agrupados:", paste(unique(dengue_clean$grupo_edad_agrupado), collapse = ", "), "\n")

# 8. RESUMEN DE CASOS POR PROVINCIA NOA ---------------------------------------
cat("\n7. RESUMEN DE CASOS EN NOA:\n")
resumen_noa <- dengue_clean %>%
  group_by(provincia) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    porcentaje_total = total_casos / sum(dengue_clean$cantidad_casos) * 100,
    registros = n()
  ) %>%
  arrange(desc(total_casos))

print(resumen_noa)

# 9. GUARDAR DATOS LIMPIOS ----------------------------------------------------
cat("8. GUARDANDO DATOS LIMPIOS...\n")

save(dengue_clean, file = "data/processed/dengue_clean.RData")
write_csv(dengue_clean, "data/processed/dengue_clean.csv")

# Resumen de limpieza
sink("outputs/reportes/resumen_limpieza.txt")
cat("RESUMEN DE LIMPIEZA - DATOS DENGUE NOA\n")
cat("======================================\n")
cat("Fecha:", format(Sys.Date(), "%Y-%m-%d"), "\n\n")
cat("FILAS ORIGINALES TOTALES:", filas_original, "\n")
cat("FILAS FINALES NOA:", nrow(dengue_clean), "\n")
cat("PORCENTAJE DE DATOS PARA NOA:", round(nrow(dengue_clean)/filas_original*100, 1), "%\n\n")

cat("PROVINCIAS NOA INCLUIDAS:\n")
for(i in 1:nrow(resumen_noa)) {
  cat("• ", resumen_noa$provincia[i], ": ", resumen_noa$total_casos[i], " casos (", 
      round(resumen_noa$porcentaje_total[i], 1), "%)\n", sep = "")
}

cat("\nVARIABLES DERIVADAS CREADAS:\n")
cat("- periodo_pandemia\n")
cat("- dummy_pandemia\n") 
cat("- trimestre_epidemio\n")
cat("- tiempo_continuo\n")
cat("- grupo_edad_agrupado\n")

cat("\nDISTRIBUCIÓN TEMPORAL EN NOA:\n")
distribucion_temporal <- dengue_clean %>%
  group_by(anio, periodo_pandemia) %>%
  summarise(total_casos = sum(cantidad_casos), .groups = 'drop')
print(distribucion_temporal)
sink()

cat("Limpieza completada\n")
cat("Datos guardados en: data/processed/dengue_clean.RData\n")
cat("Resumen en: outputs/reportes/resumen_limpieza.txt\n")