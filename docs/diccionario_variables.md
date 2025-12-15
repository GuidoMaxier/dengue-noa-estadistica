# Diccionario de Variables - Análisis Dengue NOA

## Variables Originales del Dataset

| Variable | Tipo | Descripción | Valores Posibles | Ejemplo |
|----------|------|-------------|------------------|---------|
| `anio` | Numérico | Año de registro del caso | 2018-2025 | 2024 |
| `provincia` | Texto | Provincia donde se registró el caso | Salta, Tucumán, Jujuy, Santiago del Estero, Catamarca, La Rioja | "Tucumán" |
| `departamento` | Texto | Departamento/localidad del caso | Varios departamentos por provincia | "Capital" |
| `semanas_epidemiologicas` | Numérico | Semana epidemiológica del año (1-53) | 1-53 | 15 |
| `grupo_edad` | Texto | Grupo etario del paciente | "0-4", "5-9", "10-14", "15-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80+" | "25-34" |
| `cantidad_casos` | Numérico | Número de casos registrados | ≥ 0 | 125 |
| `evento` | Texto | Tipo de evento epidemiológico | "Dengue" (principalmente) | "Dengue" |

---

## Variables Derivadas (Creadas durante el Preprocesamiento)

| Variable | Tipo | Descripción | Cómo se Calcula | Valores Posibles |
|----------|------|-------------|-----------------|------------------|
| `periodo_pandemia` | Texto | Clasificación temporal respecto a COVID-19 | `case_when(anio %in% 2020:2021 ~ "Pandemia", anio < 2020 ~ "Pre-Pandemia", anio > 2021 ~ "Post-Pandemia")` | "Pre-Pandemia", "Pandemia", "Post-Pandemia" |
| `dummy_pandemia` | Numérico | Variable binaria para modelos estadísticos | `ifelse(anio %in% 2020:2021, 1, 0)` | 0, 1 |
| `trimestre_epidemio` | Texto | Trimestre epidemiológico del año | Basado en `semanas_epidemiologicas`: 1-13 = T1, 14-26 = T2, 27-39 = T3, 40-53 = T4 | "T1 (Ene-Mar)", "T2 (Abr-Jun)", "T3 (Jul-Sep)", "T4 (Oct-Dic)" |
| `tiempo_continuo` | Numérico | Variable temporal continua para análisis de tendencias | `anio + (semanas_epidemiologicas - 1) / 52` | 2018.0 - 2025.99 |
| `grupo_edad_agrupado` | Texto | Grupos etarios reagrupados en rangos más amplios | Agrupa grupos originales: "0-4"+"5-9" = "0-9 años", etc. | "0-9 años", "10-19 años", "20-39 años", "40-59 años", "60+ años" |

---

## Notas Importantes

### Filtrado de Datos
- **Dataset original:** Incluye todas las provincias de Argentina
- **Dataset procesado:** Solo provincias del NOA (Noroeste Argentino)
- **Provincias NOA incluidas:** Salta, Tucumán, Jujuy, Santiago del Estero, Catamarca, La Rioja

### Limpieza Aplicada
- ✅ Eliminados registros con `cantidad_casos` negativos o `NA`
- ✅ Textos estandarizados con `str_to_title()` (primera letra mayúscula)
- ✅ Filtrado exclusivo de provincias NOA

### Variables Temporales
- **Semana epidemiológica:** Sistema de vigilancia epidemiológica donde el año se divide en 52-53 semanas
- **Trimestre epidemiológico:** Agrupación de semanas en 4 trimestres para análisis estacional
- **Tiempo continuo:** Permite modelar tendencias temporales de forma continua

### Variables para Análisis Estadístico
- **dummy_pandemia:** Variable binaria (0/1) usada en modelos de regresión para evaluar el efecto de la pandemia COVID-19
- **periodo_pandemia:** Variable categórica para análisis descriptivo y visualizaciones

---

## Ejemplos de Uso

### Filtrar casos del período pandémico
```r
casos_pandemia <- dengue_clean %>%
  filter(periodo_pandemia == "Pandemia")
```

### Agrupar por trimestre
```r
casos_trimestre <- dengue_clean %>%
  group_by(trimestre_epidemio) %>%
  summarise(total = sum(cantidad_casos))
```

### Análisis por grupo etario agrupado
```r
casos_edad <- dengue_clean %>%
  group_by(grupo_edad_agrupado) %>%
  summarise(total = sum(cantidad_casos))
```

---

## Referencias

- **Semanas epidemiológicas:** Sistema de vigilancia del Ministerio de Salud de Argentina
- **Clasificación etaria:** Basada en estándares epidemiológicos internacionales
- **Período pandémico:** 2020-2021 según declaración OMS de pandemia COVID-19
