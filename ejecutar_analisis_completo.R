
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

cat(" ANÁLISIS COMPLETADO EXITOSAMENTE \n")
cat(" ENTREGABLES GENERADOS:\n")
cat("   • data/processed/dengue_clean.RData\n")
cat("   • outputs/figuras/ [15+ visualizaciones]\n")
cat("   • outputs/reportes/ [5+ reportes analíticos]\n")
cat("   • outputs/tablas/ [tablas de resultados]\n")

