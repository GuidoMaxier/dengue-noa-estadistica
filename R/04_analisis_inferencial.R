# R/04_analisis_inferencial.R
# ==============================================================================
# ANÁLISIS INFERENCIAL Y MODELADO ESTADÍSTICO - DENGUE NOA
# ==============================================================================

source("00_configuracion.R")
load("data/processed/dengue_clean.RData")
load("data/processed/resultados_descriptivos.RData")

cat("=== ANÁLISIS INFERENCIAL Y MODELADO - DENGUE NOA ===\n")

# 1. PREPARAR DATOS PARA MODELOS ----------------------------------------------
cat("1. PREPARANDO DATOS PARA MODELOS...\n")

# Agrupar datos a nivel anual-provincial para regresión
datos_modelo <- dengue_clean %>%
  group_by(anio, provincia, periodo_pandemia, dummy_pandemia) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    n_registros = n(),
    .groups = 'drop'
  ) %>%
  mutate(
    # Variable tiempo centrada
    tiempo_centrado = anio - 2018,
    # Log de casos para normalizar (suavizar variabilidad)
    log_casos = log(total_casos + 1),
    # Variable cuadrática para capturar no linealidad
    tiempo_cuadratico = tiempo_centrado^2
  )

cat("• Datos para modelo:", nrow(datos_modelo), "observaciones\n")
print(head(datos_modelo))

# 2. MODELO DE REGRESIÓN LINEAL MÚLTIPLE --------------------------------------
cat("\n2. AJUSTANDO MODELOS DE REGRESIÓN...\n")

# Modelo 1: Solo tendencia temporal y provincias
modelo_basico <- lm(total_casos ~ anio + provincia, data = datos_modelo)
cat("✅ Modelo básico (temporal + provincia) ajustado\n")

# Modelo 2: Con efecto pandemia
modelo_pandemia <- lm(total_casos ~ anio + dummy_pandemia + provincia, data = datos_modelo)
cat("✅ Modelo con pandemia ajustado\n")

# Modelo 3: Con interacción provincia*año
modelo_interaccion <- lm(total_casos ~ anio * provincia + dummy_pandemia, data = datos_modelo)
cat("✅ Modelo con interacción provincia*año ajustado\n")

# 3. COMPARACIÓN DE MODELOS ---------------------------------------------------
cat("\n3. COMPARACIÓN DE MODELOS:\n")

cat("• R² Ajustado Modelo Básico:", round(summary(modelo_basico)$adj.r.squared, 4), "\n")
cat("• R² Ajustado Modelo Pandemia:", round(summary(modelo_pandemia)$adj.r.squared, 4), "\n")
cat("• R² Ajustado Modelo Interacción:", round(summary(modelo_interaccion)$adj.r.squared, 4), "\n")

# 4. ANÁLISIS DE VARIANZA (ANOVA) ---------------------------------------------
cat("\n4. ANÁLISIS DE VARIANZA...\n")

# Diferencias entre provincias
anova_provincias <- aov(total_casos ~ provincia, data = datos_modelo)
cat("✅ ANOVA por provincias completado\n")

# Diferencias entre períodos pandémicos
anova_pandemia <- aov(total_casos ~ periodo_pandemia, data = datos_modelo)
cat("✅ ANOVA por período pandémico completado\n")

# 5. PRUEBAS DE HIPÓTESIS -----------------------------------------------------
cat("\n5. PRUEBAS DE HIPÓTESIS...\n")

# Test de normalidad de residuos
residuos <- resid(modelo_pandemia)
normalidad <- shapiro.test(residuos)
cat("• Test de normalidad (Shapiro-Wilk) - Residuos: p-value =", 
    format.pval(normalidad$p.value, digits = 3), "\n")

# Test de correlación año-casos
correlacion <- cor.test(datos_modelo$anio, datos_modelo$total_casos, method = "pearson")
cat("• Correlación Pearson año-casos: r =", round(correlacion$estimate, 3), 
    ", p-value =", format.pval(correlacion$p.value, digits = 3), "\n")

# Test de homocedasticidad (Breusch-Pagan)
if(require(lmtest)) {
  homocedasticidad <- bptest(modelo_pandemia)
  cat("• Test de homocedasticidad (Breusch-Pagan): p-value =", 
      format.pval(homocedasticidad$p.value, digits = 3), "\n")
}

# 6. ANÁLISIS POST-HOC --------------------------------------------------------
cat("\n6. ANÁLISIS POST-HOC...\n")

# Comparaciones múltiples entre provincias (Tukey HSD)
if(require(multcomp)) {
  tukey_provincias <- TukeyHSD(anova_provincias)
  cat("✅ Test Tukey HSD para diferencias entre provincias completado\n")
}

# 7. RESUMEN DE MODELOS -------------------------------------------------------
cat("\n7. RESUMEN DE MODELOS:\n")

cat("MEJOR MODELO (Pandemia):\n")
print(summary(modelo_pandemia))

cat("\nCOEFICIENTES DEL MODELO PANDEMIA:\n")
coeficientes <- tidy(modelo_pandemia)
print(coeficientes)

# 8. PREDICCIONES -------------------------------------------------------------
cat("\n8. GENERANDO PREDICCIONES...\n")

# Crear datos para predicción 2026
datos_prediccion <- data.frame(
  anio = 2026,
  dummy_pandemia = 0,
  provincia = unique(datos_modelo$provincia)
)

# Predecir casos 2026
predicciones_2026 <- predict(modelo_pandemia, newdata = datos_prediccion, interval = "confidence")
predicciones_df <- cbind(datos_prediccion, predicciones_2026)

cat("• Predicciones para 2026:\n")
print(predicciones_df)

# 9. GUARDAR RESULTADOS INFERENCIALES -----------------------------------------
cat("\n9. GUARDANDO RESULTADOS...\n")

save(datos_modelo, modelo_basico, modelo_pandemia, modelo_interaccion,
     anova_provincias, anova_pandemia, normalidad, correlacion, 
     coeficientes, predicciones_df,
     file = "data/processed/resultados_inferenciales.RData")

# Reporte inferencial detallado
sink("outputs/reportes/resumen_inferencial_noa.txt")
cat("RESUMEN INFERENCIAL - ANÁLISIS DENGUE NOA 2018-2025\n")
cat("===================================================\n")
cat("Fecha:", format(Sys.Date(), "%Y-%m-%d"), "\n\n")

cat("COMPARACIÓN DE MODELOS:\n")
cat("• Modelo Básico (año + provincia): R² =", round(summary(modelo_basico)$r.squared, 4), 
    ", R²-ajustado =", round(summary(modelo_basico)$adj.r.squared, 4), "\n")
cat("• Modelo Pandemia: R² =", round(summary(modelo_pandemia)$r.squared, 4), 
    ", R²-ajustado =", round(summary(modelo_pandemia)$adj.r.squared, 4), "\n")
cat("• Modelo Interacción: R² =", round(summary(modelo_interaccion)$r.squared, 4), 
    ", R²-ajustado =", round(summary(modelo_interaccion)$adj.r.squared, 4), "\n\n")

cat("MEJOR MODELO SELECCIONADO: MODELO CON PANDEMIA\n\n")
cat("RESUMEN DEL MODELO PANDEMIA:\n")
print(summary(modelo_pandemia))

cat("\nCOEFICIENTES ESTADÍSTICAMENTE SIGNIFICATIVOS:\n")
coef_significativos <- coeficientes %>% filter(p.value < 0.05)
print(coef_significativos)

cat("\nPRUEBAS DE HIPÓTESIS:\n")
cat("• Normalidad de residuos (Shapiro-Wilk): p-value =", format.pval(normalidad$p.value, digits = 3), "\n")
cat("• Correlación año-casos (Pearson): r =", round(correlacion$estimate, 3), 
    ", p-value =", format.pval(correlacion$p.value, digits = 3), "\n")

if(exists("homocedasticidad")) {
  cat("• Homocedasticidad (Breusch-Pagan): p-value =", format.pval(homocedasticidad$p.value, digits = 3), "\n")
}

cat("\nPREDICCIONES PARA 2026:\n")
print(predicciones_df)

cat("\nINTERPRETACIÓN DE RESULTADOS:\n")
cat("• El modelo explica aproximadamente", round(summary(modelo_pandemia)$r.squared * 100, 1), "% de la variabilidad en casos de dengue\n")
cat("• El efecto de la pandemia (dummy_pandemia) es", ifelse(coeficientes$estimate[coeficientes$term == "dummy_pandemia"] > 0, "positivo", "negativo"), "\n")
cat("• Existen diferencias significativas entre provincias (p-value ANOVA:", format.pval(summary(anova_provincias)[[1]]$`Pr(>F)`[1], digits = 3), ")\n")
cat("• La tendencia temporal es", ifelse(coeficientes$estimate[coeficientes$term == "anio"] > 0, "creciente", "decreciente"), "\n")
sink()

cat("Análisis inferencial completado\n")
cat("Resultados guardados en: data/processed/resultados_inferenciales.RData\n")
cat("Reporte en: outputs/reportes/resumen_inferencial_noa.txt\n")