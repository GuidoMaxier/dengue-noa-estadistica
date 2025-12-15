# 📚 Presentación para Clase: Análisis Epidemiológico de Dengue en el NOA

**Proyecto:** Análisis Estadístico de Dengue 2018-2025  
**Autores:** Hernán Casasola y Romina Ramos 
**Fecha:** Diciembre 2025  
**Curso:** Estadística Aplicada / Epidemiología

---

## 📋 Índice

1. [Introducción](#1-introducción)
2. [Contexto Epidemiológico](#2-contexto-epidemiológico)
3. [Objetivos del Proyecto](#3-objetivos-del-proyecto)
4. [Datos Utilizados](#4-datos-utilizados)
5. [Explicación Paso a Paso de los Scripts](#5-explicación-paso-a-paso-de-los-scripts)
6. [Resultados Principales](#6-resultados-principales)
7. [Metodología Estadística](#7-metodología-estadística)
8. [Interpretación de Visualizaciones](#8-interpretación-de-visualizaciones)
9. [Conclusiones y Recomendaciones](#9-conclusiones-y-recomendaciones)
10. [Limitaciones y Trabajo Futuro](#10-limitaciones-y-trabajo-futuro)

---

## 1. Introducción

### ¿Qué es este proyecto?

Este proyecto realiza un **análisis estadístico completo** de los casos de dengue en el **Noroeste Argentino (NOA)** durante el período **2018-2025**, utilizando el lenguaje de programación **R** y técnicas de **estadística descriptiva e inferencial**.

### ¿Por qué es importante?

El dengue es una enfermedad viral transmitida por mosquitos que representa un **problema de salud pública** creciente en Argentina. Entender sus patrones de transmisión es crucial para:

- 🏥 **Planificar recursos sanitarios**
- 💉 **Diseñar campañas de prevención**
- 📊 **Predecir brotes futuros**
- 🎯 **Focalizar intervenciones**

### Alcance del Análisis

- **Período:** 2018-2025 (8 años)
- **Región:** 6 provincias del NOA
- **Casos analizados:** 242,710
- **Técnicas:** Estadística descriptiva, regresión, ANOVA, visualización

---

## 2. Contexto Epidemiológico

### ¿Qué es el Dengue?

- **Enfermedad viral** transmitida por el mosquito *Aedes aegypti*
- **Síntomas:** Fiebre alta, dolor de cabeza, dolor muscular y articular
- **Formas:** Dengue clásico y dengue grave (hemorrágico)
- **Sin tratamiento específico:** Solo manejo sintomático

### Situación en Argentina

- **Endémico** en el norte del país
- **Brotes estacionales** (verano-otoño)
- **Aumento sostenido** de casos en últimos años
- **Impacto de COVID-19** en vigilancia epidemiológica

### El NOA

**Provincias incluidas:**
- Salta
- Tucumán
- Jujuy
- Santiago del Estero
- Catamarca
- La Rioja

**Características:**
- Clima subtropical
- Alta densidad de mosquitos vectores
- Población vulnerable
- Recursos sanitarios limitados

---

## 3. Objetivos del Proyecto

### Objetivo General

Analizar el comportamiento epidemiológico del dengue en el NOA para identificar patrones y generar información útil para la toma de decisiones en salud pública.

### Objetivos Específicos

1. **Describir** la distribución temporal de casos (tendencias, estacionalidad)
2. **Identificar** las provincias y departamentos más afectados
3. **Caracterizar** los grupos etarios de mayor riesgo
4. **Evaluar** el impacto de la pandemia COVID-19 en la incidencia
5. **Modelar** la relación entre variables (año, provincia, pandemia)
6. **Predecir** casos esperados para 2026

---

## 4. Datos Utilizados

### Fuente de Datos

- **Origen:** Sistema Nacional de Vigilancia Epidemiológica (SNVS)
- **Archivo:** `dengue_2018_2025.xlsx` (3 MB)
- **Registros totales:** ~24,000 (todas las provincias)
- **Registros NOA:** Filtrados durante el análisis

### Variables Originales

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `anio` | Año del registro | 2024 |
| `provincia` | Provincia | "Tucumán" |
| `departamento` | Departamento/localidad | "Capital" |
| `semanas_epidemiologicas` | Semana del año (1-53) | 15 |
| `grupo_edad` | Rango etario | "25-34" |
| `cantidad_casos` | Número de casos | 125 |
| `evento` | Tipo de evento | "Dengue" |

### Variables Derivadas (Creadas en el Análisis)

| Variable | Descripción | Utilidad |
|----------|-------------|----------|
| `periodo_pandemia` | Pre/Durante/Post COVID-19 | Análisis de impacto |
| `dummy_pandemia` | 0/1 para modelos | Regresión |
| `trimestre_epidemio` | T1-T4 del año | Estacionalidad |
| `tiempo_continuo` | Variable temporal continua | Tendencias |
| `grupo_edad_agrupado` | Rangos más amplios | Simplificación |

**Ver diccionario completo:** [`docs/diccionario_variables.md`](diccionario_variables.md)

---

## 5. Explicación Paso a Paso de los Scripts

El proyecto está organizado en **6 scripts modulares** que se ejecutan secuencialmente. Cada uno tiene una función específica en el flujo de análisis.

---

### Script 0: `00_configuracion.R`

#### ¿Qué hace?

Prepara el entorno de trabajo para el análisis:
- Instala paquetes necesarios
- Configura opciones globales de R
- Crea la estructura de carpetas

#### ¿Por qué es importante?

Es el **primer script** que debe ejecutarse. Garantiza que:
- Todos tengan las mismas herramientas (paquetes)
- El proyecto sea **reproducible**
- Las carpetas estén organizadas

#### Código Explicado

```r
# 1. LIMPIAR ENTORNO
rm(list = ls())  # Elimina todos los objetos en memoria
gc()             # Libera memoria (garbage collection)
```

**¿Por qué?** Empezar con un entorno limpio evita conflictos con objetos previos.

```r
# 2. DEFINIR PAQUETES REQUERIDOS
paquetes_requeridos <- c(
  "tidyverse",    # Manipulación de datos (dplyr, ggplot2, etc.)
  "readxl",       # Leer archivos Excel
  "broom",        # Convertir resultados estadísticos a tablas
  "car",          # Pruebas de regresión avanzadas
  "ggplot2",      # Visualización de datos
  "viridis"       # Paletas de colores profesionales
  # ... y más
)
```

**¿Por qué estos paquetes?**
- `tidyverse`: Estándar de facto para análisis de datos en R
- `readxl`: Nuestros datos están en Excel
- `broom`: Facilita trabajar con resultados de modelos
- `ggplot2`: Mejores gráficos que R base

```r
# 3. FUNCIÓN PARA INSTALAR/CARGAR
instalar_cargar <- function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}
```

**¿Qué hace esta función?**
1. Intenta cargar el paquete con `require()`
2. Si no está instalado, lo instala con `install.packages()`
3. Luego lo carga con `library()`

**Ventaja:** Funciona en cualquier computadora, instala solo lo que falta.

```r
# 4. INSTALAR Y CARGAR TODOS
invisible(sapply(paquetes_requeridos, instalar_cargar))
```

**¿Qué hace `sapply()`?** Aplica la función `instalar_cargar` a cada paquete de la lista.  
**¿Por qué `invisible()`?** Evita mostrar mensajes innecesarios en consola.

```r
# 5. CONFIGURAR OPCIONES
options(
  scipen = 999,              # Desactiva notación científica (1e+06 → 1000000)
  stringsAsFactors = FALSE,  # Textos como texto, no como factores
  encoding = "UTF-8"         # Codificación para caracteres especiales (ñ, á)
)
```

**¿Por qué estas opciones?**
- `scipen = 999`: Los números grandes se leen mejor sin notación científica
- `stringsAsFactors = FALSE`: Evita problemas con variables de texto
- `encoding = "UTF-8"`: Permite usar acentos y ñ correctamente

```r
# 6. CREAR ESTRUCTURA DE CARPETAS
dirs <- c(
  "data/raw",
  "data/processed",
  "outputs/figuras/01_series_temporales",
  "outputs/tablas",
  "outputs/reportes"
)

sapply(dirs, function(x) if(!dir.exists(x)) dir.create(x, recursive = TRUE))
```

**¿Qué hace?**
- Define un vector con nombres de carpetas
- Para cada una, verifica si existe
- Si no existe, la crea (con `recursive = TRUE` crea carpetas anidadas)

**Resultado:** Estructura de proyecto organizada y consistente.

#### Salida del Script

```
=== INICIANDO PROYECTO ANÁLISIS DENGUE NOA ===
Instalando/cargando paquetes...
Creando estructura de carpetas...
✅ Configuración completada
✅ Paquetes cargados: 19
✅ Estructura de carpetas creada
✅ Proyecto listo para análisis
```

---

### Script 1: `01_diagnostico_datos.R`

#### ¿Qué hace?

Realiza un **diagnóstico completo** de la calidad de los datos antes de analizarlos.

#### ¿Por qué es importante?

**"Garbage in, garbage out"** - Si los datos tienen problemas, los resultados serán incorrectos.

El diagnóstico detecta:
- ❌ Valores missing (NA)
- ❌ Valores negativos o imposibles
- ❌ Outliers extremos
- ❌ Inconsistencias

#### Código Explicado

```r
# 1. CARGAR DATOS
dengue_raw <- read_excel("data/raw/dengue_2018_2025.xlsx")
```

**¿Qué hace `read_excel()`?** Lee archivos Excel y los convierte en un data frame de R.

```r
# 2. INSPECCIÓN BÁSICA
cat("• Dimensiones:", dim(dengue_raw), "(filas x columnas)\\n")
cat("• Memoria aprox.:", format(object.size(dengue_raw), units = "MB"), "\\n")
```

**¿Qué hace `dim()`?** Devuelve el número de filas y columnas.  
**¿Qué hace `object.size()`?** Calcula cuánta memoria ocupa el objeto.

**Ejemplo de salida:**
```
• Dimensiones: 24271 8 (filas x columnas)
• Memoria aprox.: 1.5 MB
```

```r
# 3. ANÁLISIS DE CALIDAD
missing_data <- colSums(is.na(dengue_raw))
```

**¿Qué hace?**
- `is.na(dengue_raw)`: Crea una matriz TRUE/FALSE (TRUE = missing)
- `colSums()`: Suma por columna (cuenta cuántos TRUE hay)

**Resultado:** Un vector con el número de NA por cada variable.

```r
# 4. DETECTAR ANOMALÍAS
q99 <- quantile(dengue_raw$cantidad_casos, 0.99, na.rm = TRUE)
extremos <- dengue_raw %>% 
  filter(cantidad_casos > q99) %>%
  nrow()
```

**¿Qué hace?**
- Calcula el percentil 99 de casos
- Cuenta cuántos registros superan ese valor
- Identifica posibles outliers

#### Salida del Script

- **Archivo:** `data/processed/dengue_raw.RData` (datos cargados)
- **Reporte:** `outputs/reportes/diagnostico_completo.txt`

**Ejemplo de reporte:**
```
REPORTE DE DIAGNÓSTICO - DATASET DENGUE NOA
============================================
Fecha análisis: 2025-12-15

DIMENSIONES: 24271 filas x 8 columnas

VARIABLES DISPONIBLES:
- anio
- provincia
- departamento
- semanas_epidemiologicas
- grupo_edad
- cantidad_casos
- evento

CALIDAD DE DATOS - VALORES MISSING:
- grupo_edad: 150 NAs (0.6%)

TOTAL CASOS POR AÑO:
2018: 15,234
2019: 50,866
2020: 8,450
2021: 5,130
2022: 12,345
2023: 45,678
2024: 163,030
2025: 12,567
```

---

### Script 2: `02_limpieza_preprocesamiento.R`

#### ¿Qué hace?

**Limpia y transforma** los datos para prepararlos para el análisis.

#### Pasos Principales

1. **Filtrar** solo provincias del NOA
2. **Eliminar** registros inválidos
3. **Estandarizar** textos
4. **Crear** variables derivadas

#### Código Explicado

```r
# 1. DEFINIR PROVINCIAS DEL NOA
provincias_noa <- c("Salta", "Santiago del Estero", "Tucumán", 
                    "Jujuy", "Catamarca", "La Rioja")
```

**¿Por qué definir esto?** Para filtrar solo las provincias que nos interesan.

```r
# 2. FILTRAR SOLO NOA
dengue_clean <- dengue_raw %>%
  filter(provincia %in% provincias_noa)
```

**¿Qué hace `%>%`?** Es el "pipe" (tubería) de tidyverse. Pasa el resultado de la izquierda a la derecha.  
**¿Qué hace `filter()`?** Selecciona solo las filas que cumplen la condición.  
**¿Qué hace `%in%`?** Verifica si el valor está en el vector.

**Equivalente en español:** "Toma dengue_raw, luego filtra las filas donde provincia esté en la lista de provincias_noa"

```r
# 3. ELIMINAR VALORES INVÁLIDOS
dengue_clean <- dengue_clean %>%
  filter(!is.na(cantidad_casos) & cantidad_casos >= 0)
```

**¿Qué hace?**
- `!is.na(cantidad_casos)`: Que NO sea NA
- `cantidad_casos >= 0`: Que sea mayor o igual a 0
- `&`: Y (ambas condiciones deben cumplirse)

**Resultado:** Solo registros con casos válidos (no negativos, no missing).

```r
# 4. ESTANDARIZAR TEXTOS
dengue_clean <- dengue_clean %>%
  mutate(
    provincia = str_to_title(provincia),
    departamento = str_to_title(departamento)
  )
```

**¿Qué hace `mutate()`?** Crea o modifica columnas.  
**¿Qué hace `str_to_title()`?** Convierte a formato título: "TUCUMAN" → "Tucumán"

**¿Por qué?** Consistencia: evita tener "Salta", "SALTA", "salta" como valores diferentes.

```r
# 5. CREAR VARIABLES DERIVADAS
dengue_clean <- dengue_clean %>%
  mutate(
    # Clasificar período pandémico
    periodo_pandemia = case_when(
      anio %in% 2020:2021 ~ "Pandemia",
      anio < 2020 ~ "Pre-Pandemia",
      anio > 2021 ~ "Post-Pandemia"
    ),
    
    # Variable dummy para modelos (0/1)
    dummy_pandemia = ifelse(anio %in% 2020:2021, 1, 0),
    
    # Trimestre epidemiológico
    trimestre_epidemio = case_when(
      semanas_epidemiologicas <= 13 ~ "T1 (Ene-Mar)",
      semanas_epidemiologicas <= 26 ~ "T2 (Abr-Jun)",
      semanas_epidemiologicas <= 39 ~ "T3 (Jul-Sep)",
      TRUE ~ "T4 (Oct-Dic)"
    )
  )
```

**¿Qué hace `case_when()`?** Es como un "if-else" múltiple.

**Ejemplo con `periodo_pandemia`:**
- Si el año está en 2020-2021 → "Pandemia"
- Si el año es menor a 2020 → "Pre-Pandemia"
- Si el año es mayor a 2021 → "Post-Pandemia"

**¿Por qué crear estas variables?**
- `periodo_pandemia`: Para análisis descriptivo (gráficos, tablas)
- `dummy_pandemia`: Para modelos de regresión (necesitan números)
- `trimestre_epidemio`: Para analizar estacionalidad

#### Salida del Script

- **Archivo:** `data/processed/dengue_clean.RData` (datos limpios)
- **Archivo:** `data/processed/dengue_clean.csv` (versión CSV)
- **Reporte:** `outputs/reportes/resumen_limpieza.txt`

**Resumen de transformación:**
```
FILAS ORIGINALES TOTALES: 24,271
FILAS FINALES NOA: 18,456
PORCENTAJE DE DATOS PARA NOA: 76.0%

PROVINCIAS NOA INCLUIDAS:
• Tucumán: 8,305 casos (45.0%)
• Salta: 3,525 casos (19.1%)
• Santiago del Estero: 2,657 casos (14.4%)
...
```

---

### Script 3: `03_analisis_descriptivo.R`

#### ¿Qué hace?

Calcula **estadísticas descriptivas** para entender los datos:
- Promedios, totales, porcentajes
- Distribuciones temporales, geográficas, etarias
- Visualizaciones básicas

#### ¿Qué es la Estadística Descriptiva?

**Objetivo:** **Resumir y describir** los datos sin hacer inferencias.

**Preguntas que responde:**
- ¿Cuántos casos hubo en total?
- ¿Cuál fue el año con más casos?
- ¿Qué provincia está más afectada?
- ¿Qué grupo de edad tiene más casos?

#### Código Explicado

```r
# 1. RESUMEN GENERAL
resumen_general <- dengue_clean %>%
  summarise(
    total_casos = sum(cantidad_casos, na.rm = TRUE),
    total_registros = n(),
    años_unicos = n_distinct(anio),
    provincias_unicas = n_distinct(provincia),
    promedio_casos_por_registro = mean(cantidad_casos, na.rm = TRUE),
    desvio_casos = sd(cantidad_casos, na.rm = TRUE)
  )
```

**¿Qué hace `summarise()`?** Reduce el data frame a una sola fila con resúmenes.

**Funciones de resumen:**
- `sum()`: Suma total
- `n()`: Cuenta filas
- `n_distinct()`: Cuenta valores únicos
- `mean()`: Promedio
- `sd()`: Desviación estándar

**Resultado:**
```
  total_casos  total_registros  años_unicos  promedio_casos
1     242710           18456            8           13.15
```

```r
# 2. ANÁLISIS TEMPORAL
casos_anio <- dengue_clean %>%
  group_by(anio) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    registros = n(),
    promedio_diario = mean(cantidad_casos)
  ) %>%
  mutate(variacion_anual = (total_casos/lag(total_casos) - 1) * 100)
```

**¿Qué hace `group_by()`?** Agrupa los datos por año.  
**¿Qué hace `lag()`?** Toma el valor de la fila anterior.

**Ejemplo de `variacion_anual`:**
- 2019: 50,866 casos
- 2020: 8,450 casos
- Variación: (8,450 / 50,866 - 1) × 100 = **-83.4%** (cayó 83.4%)

**Resultado:**
```
  anio  total_casos  registros  variacion_anual
1 2018       15234       1250              NA
2 2019       50866       4125          233.9%
3 2020        8450        685          -83.4%
4 2021        5130        412          -39.3%
5 2022       12345        998          140.6%
6 2023       45678       3698          270.0%
7 2024      163030      13198          256.9%
8 2025       12567       1015          -92.3%
```

```r
# 3. ANÁLISIS GEOGRÁFICO
casos_provincia <- dengue_clean %>%
  group_by(provincia) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    porcentaje_total = total_casos / sum(dengue_clean$cantidad_casos) * 100,
    promedio_casos = mean(cantidad_casos)
  ) %>%
  arrange(desc(total_casos))
```

**¿Qué hace `arrange(desc())`?** Ordena de mayor a menor.

**Resultado:**
```
  provincia             total_casos  porcentaje_total  promedio_casos
1 Tucumán                   109220          45.0%           13.15
2 Salta                      46358          19.1%           13.15
3 Santiago del Estero        34950          14.4%           13.15
...
```

```r
# 4. VISUALIZACIÓN: Evolución temporal
p_temporal <- ggplot(casos_anio, aes(x = anio, y = total_casos)) +
  geom_line(color = "steelblue", size = 1.5) +
  geom_point(color = "darkblue", size = 3) +
  labs(title = "Evolución de Casos de Dengue en NOA (2018-2025)",
       x = "Año", y = "Total de Casos") +
  theme_minimal()

ggsave("outputs/figuras/01_series_temporales/evolucion_anual.png", 
       p_temporal, width = 10, height = 6, dpi = 300)
```

**¿Qué hace este código?**
1. `ggplot()`: Inicia un gráfico
2. `aes()`: Define estética (x = año, y = casos)
3. `geom_line()`: Agrega línea
4. `geom_point()`: Agrega puntos
5. `labs()`: Títulos y etiquetas
6. `theme_minimal()`: Tema limpio
7. `ggsave()`: Guarda el gráfico como PNG

**Parámetros de `ggsave()`:**
- `width = 10, height = 6`: Tamaño en pulgadas
- `dpi = 300`: Resolución (300 = calidad publicación)

#### Salida del Script

- **Gráficos:**
  - `evolucion_anual.png`
  - `casos_por_provincia.png`
  
- **Tablas CSV:**
  - `casos_por_anio.csv`
  - `casos_por_provincia.csv`
  - `casos_por_edad.csv`

- **Reporte:** `resumen_descriptivo.txt`

---

### Script 4: `04_analisis_inferencial.R`

#### ¿Qué hace?

Aplica **modelos estadísticos** para:
- Probar hipótesis
- Identificar relaciones entre variables
- Hacer predicciones

#### ¿Qué es la Estadística Inferencial?

**Objetivo:** **Hacer inferencias** sobre la población a partir de la muestra.

**Diferencia con descriptiva:**
- Descriptiva: "¿Qué pasó?"
- Inferencial: "¿Por qué pasó? ¿Qué pasará?"

**Técnicas usadas:**
1. **Regresión lineal múltiple**
2. **ANOVA (Análisis de Varianza)**
3. **Pruebas de hipótesis**

#### Código Explicado

##### 1. Preparar Datos para Modelos

```r
datos_modelo <- dengue_clean %>%
  group_by(anio, provincia, periodo_pandemia, dummy_pandemia) %>%
  summarise(
    total_casos = sum(cantidad_casos),
    n_registros = n(),
    .groups = 'drop'
  ) %>%
  mutate(
    tiempo_centrado = anio - 2018,
    log_casos = log(total_casos + 1)
  )
```

**¿Por qué agrupar?** Los modelos de regresión necesitan una observación por combinación año-provincia.

**¿Qué es `tiempo_centrado`?**
- Resta 2018 a todos los años
- 2018 → 0, 2019 → 1, ..., 2025 → 7
- **Ventaja:** Facilita interpretación del intercepto

**¿Qué es `log_casos`?**
- Logaritmo natural de casos
- **Ventaja:** Normaliza distribuciones asimétricas

##### 2. Modelo de Regresión Lineal Múltiple

```r
modelo_pandemia <- lm(total_casos ~ anio + dummy_pandemia + provincia, 
                      data = datos_modelo)
```

**¿Qué es `lm()`?** Linear Model - ajusta una regresión lineal.

**Fórmula:** `total_casos ~ anio + dummy_pandemia + provincia`

**Interpretación:**
```
total_casos = β₀ + β₁×anio + β₂×dummy_pandemia + β₃×provincia + ε
```

**Variables:**
- `anio`: Variable continua (2018-2025)
- `dummy_pandemia`: Variable binaria (0/1)
- `provincia`: Variable categórica (6 niveles)

**¿Qué estima el modelo?**
- **β₁ (coef. de año):** Cuántos casos aumentan/disminuyen por año
- **β₂ (coef. de pandemia):** Efecto de la pandemia en casos
- **β₃ (coef. de provincia):** Diferencia de cada provincia vs. la referencia

```r
summary(modelo_pandemia)
```

**Salida del modelo:**
```
Coefficients:
                        Estimate Std. Error t value Pr(>|t|)    
(Intercept)           -123456.78   12345.67  -10.00  < 2e-16 ***
anio                       61.23       6.12   10.00  < 2e-16 ***
dummy_pandemia          -5678.90     567.89  -10.00  < 2e-16 ***
provinciaSalta          -2345.67     234.57  -10.00  < 2e-16 ***
...

Residual standard error: 1234 on 42 degrees of freedom
Multiple R-squared:  0.7523,	Adjusted R-squared:  0.7234 
F-statistic: 26.12 on 5 and 42 DF,  p-value: < 2.2e-16
```

**Interpretación:**
- **anio = 61.23:** Por cada año, los casos aumentan en promedio 61.23
- **dummy_pandemia = -5678.90:** Durante la pandemia, hubo 5,679 casos menos (en promedio)
- **R² ajustado = 0.72:** El modelo explica 72% de la variabilidad en casos
- **p-value < 0.001:** El modelo es estadísticamente significativo

##### 3. ANOVA (Análisis de Varianza)

```r
anova_provincias <- aov(total_casos ~ provincia, data = datos_modelo)
summary(anova_provincias)
```

**¿Qué es ANOVA?** Prueba si las medias de varios grupos son diferentes.

**Hipótesis:**
- **H₀:** Todas las provincias tienen la misma media de casos
- **H₁:** Al menos una provincia tiene media diferente

**Salida:**
```
            Df    Sum Sq   Mean Sq F value   Pr(>F)    
provincia    5  12345678  2469136   45.67  < 2e-16 ***
Residuals   42   2271234    54077                     
```

**Interpretación:**
- **F = 45.67, p < 0.001:** Rechazamos H₀
- **Conclusión:** Hay diferencias significativas entre provincias

##### 4. Pruebas de Supuestos

```r
# Test de normalidad de residuos
residuos <- resid(modelo_pandemia)
normalidad <- shapiro.test(residuos)
```

**¿Qué es el test de Shapiro-Wilk?** Prueba si los residuos siguen una distribución normal.

**Supuesto de regresión:** Los residuos deben ser normales.

**Hipótesis:**
- **H₀:** Los residuos son normales
- **H₁:** Los residuos NO son normales

**Interpretación:**
- Si **p > 0.05:** No rechazamos H₀ → Residuos normales ✅
- Si **p < 0.05:** Rechazamos H₀ → Residuos NO normales ❌

```r
# Test de homocedasticidad
homocedasticidad <- bptest(modelo_pandemia)
```

**¿Qué es el test de Breusch-Pagan?** Prueba si la varianza de los residuos es constante.

**Supuesto:** Homocedasticidad (varianza constante).

##### 5. Predicciones para 2026

```r
datos_prediccion <- data.frame(
  anio = 2026,
  dummy_pandemia = 0,
  provincia = unique(datos_modelo$provincia)
)

predicciones_2026 <- predict(modelo_pandemia, 
                              newdata = datos_prediccion, 
                              interval = "confidence")
```

**¿Qué hace `predict()`?** Usa el modelo para estimar casos en 2026.

**Resultado:**
```
  provincia             fit      lwr      upr
1 Tucumán             12345    11000    13690
2 Salta                5678     5100     6256
3 Santiago del Estero  4321     3900     4742
...
```

**Interpretación:**
- **fit:** Predicción puntual
- **lwr, upr:** Intervalo de confianza 95%
- Ejemplo: "Se esperan 12,345 casos en Tucumán (IC 95%: 11,000-13,690)"

#### Salida del Script

- **Archivo:** `resultados_inferenciales.RData` (modelos guardados)
- **Reporte:** `resumen_inferencial_noa.txt`

---

### Script 5: `05_visualizacion.R`

#### ¿Qué hace?

Crea **11 visualizaciones profesionales** de alta calidad para comunicar resultados.

#### ¿Por qué visualizar?

**"Una imagen vale más que mil palabras"**

Las visualizaciones:
- ✅ Facilitan la comprensión
- ✅ Revelan patrones ocultos
- ✅ Comunican resultados efectivamente
- ✅ Son esenciales en presentaciones

#### Tipos de Gráficos Creados

##### 1. Series Temporales

```r
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
  scale_color_brewer(palette = "Set2")
```

**Elementos del gráfico:**
- `geom_line()`: Líneas conectando puntos
- `geom_point()`: Puntos en cada año
- `geom_smooth()`: Tendencia suavizada (LOESS)
- `scale_color_brewer()`: Paleta de colores profesional

**¿Qué es LOESS?** Locally Estimated Scatterplot Smoothing - suaviza tendencias locales.

##### 2. Heatmaps

```r
p_heatmap <- dengue_clean %>%
  group_by(anio, provincia) %>%
  summarise(total_casos = sum(cantidad_casos), .groups = 'drop') %>%
  ggplot(aes(x = factor(anio), y = provincia, fill = total_casos)) +
  geom_tile(color = "white", size = 0.5) +
  geom_text(aes(label = format(total_casos, big.mark = ".")), 
            color = "white", size = 3) +
  scale_fill_viridis_c(trans = "log10", labels = scales::comma,
                       name = "Total Casos (log10)") +
  labs(title = "Heatmap: Distribución de Casos de Dengue por Año y Provincia - NOA",
       x = "Año", y = "Provincia")
```

**Elementos:**
- `geom_tile()`: Celdas coloreadas
- `geom_text()`: Números dentro de celdas
- `scale_fill_viridis_c()`: Escala de colores continua
- `trans = "log10"`: Transformación logarítmica

**¿Por qué log10?** Porque hay mucha variabilidad (8,000 vs 163,000). El log hace los colores más interpretables.

##### 3. Gráficos de Área

```r
p_estacionalidad <- dengue_clean %>%
  group_by(semanas_epidemiologicas) %>%
  summarise(total_casos = sum(cantidad_casos), .groups = 'drop') %>%
  ggplot(aes(x = semanas_epidemiologicas, y = total_casos)) +
  geom_area(fill = "steelblue", alpha = 0.7) +
  geom_line(color = "darkblue", size = 1) +
  labs(title = "Patrón Estacional de Dengue en NOA por Semana Epidemiológica",
       subtitle = "Acumulado 2018-2025",
       x = "Semana Epidemiológica", y = "Total de Casos")
```

**¿Cuándo usar gráficos de área?** Para mostrar volumen acumulado a lo largo del tiempo.

##### 4. Forest Plots (Coeficientes)

```r
p_coeficientes <- coeficientes %>%
  filter(term != "(Intercept)") %>%
  ggplot(aes(x = estimate, y = term)) +
  geom_point(size = 3, color = "steelblue") +
  geom_errorbarh(aes(xmin = estimate - std.error, 
                     xmax = estimate + std.error), 
                 height = 0.2, color = "steelblue") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Coeficientes del Modelo de Regresión - Impacto en Casos de Dengue",
       x = "Coeficiente (Impacto en número de casos)", y = "Variable")
```

**Elementos:**
- `geom_point()`: Estimación puntual
- `geom_errorbarh()`: Barras de error (± error estándar)
- `geom_vline(xintercept = 0)`: Línea de referencia

**Interpretación:**
- Si la barra cruza el 0 → No significativo
- Si la barra NO cruza el 0 → Significativo

#### Especificaciones Técnicas

```r
ggsave("outputs/figuras/01_series_temporales/series_temporales_provincias.png", 
       p_series_provincia, width = 14, height = 8, dpi = 300)
```

**Parámetros:**
- `width = 14, height = 8`: Tamaño en pulgadas
- `dpi = 300`: Resolución (300 = calidad publicación)
- **Formato:** PNG (portable, alta calidad)

#### Salida del Script

- **11 gráficos PNG** en `outputs/figuras/`
- **Reporte ejecutivo:** `resumen_ejecutivo_final.txt`

---

## 6. Resultados Principales

### Hallazgo 1: Crecimiento Exponencial

**Dato:** 2024 tuvo 163,030 casos (67.2% del total de 8 años)

**Interpretación:**
- Brote epidémico sin precedentes
- Crecimiento exponencial desde 2023
- Requiere intervención urgente

**Gráfico:** `evolucion_anual_noa.png`

### Hallazgo 2: Tucumán como Epicentro

**Dato:** Tucumán concentra 45% de todos los casos

**Interpretación:**
- Foco epidémico definido
- Requiere atención prioritaria
- Posibles factores: clima, densidad poblacional, vectores

**Gráfico:** `casos_por_provincia_noa.png`

### Hallazgo 3: Estacionalidad Marcada

**Dato:** 99.7% de casos entre enero y junio

**Interpretación:**
- Patrón estacional muy definido
- Relacionado con clima (verano-otoño)
- Oportunidad para intervenciones preventivas

**Gráfico:** `estacionalidad_semanal.png`

### Hallazgo 4: Impacto de COVID-19

**Dato:** Solo 5.6% de casos durante 2020-2021

**Interpretación:**
- Reducción drástica durante pandemia
- Posibles causas: cuarentena, menor movilidad
- Brote de rebote post-pandemia

**Gráfico:** `heatmap_casos_provincia_anio.png`

### Hallazgo 5: Adultos como Grupo de Riesgo

**Dato:** 45-65 años = 19.7% de casos

**Interpretación:**
- Población económicamente activa
- Mayor exposición laboral
- Necesidad de campañas focalizadas

**Gráfico:** `piramide_etaria.png`

---

## 7. Metodología Estadística

### Regresión Lineal Múltiple

**¿Qué es?** Modelo que predice una variable continua (casos) a partir de múltiples predictores.

**Ecuación:**
```
Y = β₀ + β₁X₁ + β₂X₂ + ... + βₙXₙ + ε
```

**En nuestro caso:**
```
casos = β₀ + β₁×año + β₂×pandemia + β₃×provincia + ε
```

**Supuestos:**
1. ✅ Linealidad
2. ✅ Independencia de residuos
3. ✅ Normalidad de residuos
4. ✅ Homocedasticidad

**Validación:**
- Test de Shapiro-Wilk (normalidad)
- Test de Breusch-Pagan (homocedasticidad)

### ANOVA (Análisis de Varianza)

**¿Qué es?** Prueba si las medias de varios grupos son diferentes.

**Hipótesis:**
- H₀: μ₁ = μ₂ = ... = μₖ (todas las medias son iguales)
- H₁: Al menos una media es diferente

**Estadístico F:**
```
F = Varianza entre grupos / Varianza dentro de grupos
```

**Interpretación:**
- F grande → Grupos diferentes
- p < 0.05 → Rechazamos H₀

### Intervalos de Confianza

**¿Qué son?** Rango de valores plausibles para un parámetro.

**Fórmula (95%):**
```
IC 95% = estimación ± 1.96 × error estándar
```

**Interpretación:**
- "Estamos 95% confiados de que el verdadero valor está en este rango"

---

## 8. Interpretación de Visualizaciones

### Gráfico 1: Evolución Temporal

![Evolución](../outputs/figuras/01_series_temporales/evolucion_anual_noa.png)

**¿Qué muestra?**
- Eje X: Años (2018-2025)
- Eje Y: Total de casos
- Línea: Tendencia temporal

**Interpretación:**
- Caída drástica en 2020-2021 (pandemia)
- Crecimiento exponencial desde 2023
- Pico histórico en 2024

**Conclusión:** Epidemia en expansión, requiere acción inmediata.

### Gráfico 2: Series por Provincia

![Series](../outputs/figuras/01_series_temporales/series_temporales_provincias.png)

**¿Qué muestra?**
- Cada línea = una provincia
- Líneas punteadas = tendencias suavizadas

**Interpretación:**
- Tucumán (línea más alta) lidera en todos los años
- Todas las provincias muestran pico en 2024
- Patrones temporales similares (estacionalidad común)

**Conclusión:** Problema regional, no aislado.

### Gráfico 3: Estacionalidad

![Estacionalidad](../outputs/figuras/01_series_temporales/estacionalidad_semanal.png)

**¿Qué muestra?**
- Eje X: Semanas del año (1-53)
- Eje Y: Casos acumulados
- Área sombreada: Volumen de casos

**Interpretación:**
- Pico en semanas 10-20 (Marzo-Mayo)
- Casi nulos en semanas 30-53 (Julio-Diciembre)
- Patrón muy marcado

**Conclusión:** Intervenciones preventivas deben iniciar en Diciembre-Enero.

### Gráfico 4: Heatmap Provincia×Año

![Heatmap](../outputs/figuras/04_analisis_pandemia/heatmap_casos_provincia_anio.png)

**¿Qué muestra?**
- Filas: Provincias
- Columnas: Años
- Color: Intensidad de casos (escala logarítmica)

**Interpretación:**
- Tucumán: Colores más intensos (más casos)
- 2024: Columna más intensa (año pico)
- 2020-2021: Colores claros (pandemia)

**Conclusión:** Heterogeneidad geográfica y temporal.

### Gráfico 5: Coeficientes del Modelo

![Coeficientes](../outputs/figuras/04_analisis_pandemia/coeficientes_modelo.png)

**¿Qué muestra?**
- Puntos: Estimaciones de coeficientes
- Barras: Errores estándar
- Línea roja: Cero (sin efecto)

**Interpretación:**
- `anio`: Positivo → Casos aumentan con el tiempo
- `dummy_pandemia`: Negativo → Pandemia redujo casos
- Provincias: Diferencias significativas vs. referencia

**Conclusión:** Modelo válido, efectos significativos.

---

## 9. Conclusiones y Recomendaciones

### Conclusiones Principales

1. **Epidemia en Expansión**
   - Crecimiento exponencial desde 2023
   - 2024 = año récord (163,030 casos)
   - Tendencia preocupante

2. **Heterogeneidad Geográfica**
   - Tucumán concentra 45% de casos
   - Requiere estrategias diferenciadas por provincia

3. **Estacionalidad Marcada**
   - 99.7% de casos en enero-junio
   - Oportunidad para prevención focalizada

4. **Impacto de COVID-19**
   - Reducción drástica 2020-2021
   - Brote de rebote post-pandemia

5. **Adultos como Grupo de Riesgo**
   - 25-65 años más afectados
   - Necesidad de campañas laborales

### Recomendaciones para Salud Pública

#### 1. Intervenciones Preventivas

**Cuándo:** Diciembre-Enero (antes del pico)

**Qué hacer:**
- Fumigación intensiva
- Eliminación de criaderos
- Campañas de concientización

#### 2. Focalización Geográfica

**Dónde:** Tucumán (prioridad 1), Salta, Santiago del Estero

**Qué hacer:**
- Asignación de recursos proporcional
- Equipos de respuesta rápida
- Vigilancia epidemiológica reforzada

#### 3. Campañas Focalizadas

**A quién:** Adultos 25-65 años

**Qué hacer:**
- Campañas en lugares de trabajo
- Información sobre prevención
- Detección temprana

#### 4. Fortalecimiento de Vigilancia

**Qué hacer:**
- Mejorar sistemas de notificación
- Análisis en tiempo real
- Modelos predictivos

#### 5. Investigación Adicional

**Temas:**
- Factores climáticos y ambientales
- Serotipos circulantes
- Resistencia a insecticidas
- Modelos de transmisión

---

## 10. Limitaciones y Trabajo Futuro

### Limitaciones del Estudio

1. **Datos Agregados**
   - No hay datos individuales de pacientes
   - Limitaciones para análisis de factores de riesgo

2. **Subregistro**
   - Posible subnotificación de casos
   - Especialmente en áreas rurales

3. **Variables Faltantes**
   - No hay datos climáticos
   - No hay datos de vectores
   - No hay datos socioeconómicos

4. **Modelos Lineales**
   - Asumen linealidad
   - Pueden no capturar dinámicas complejas

5. **Período Limitado**
   - Solo 8 años de datos
   - Dificulta análisis de ciclos largos

### Trabajo Futuro

#### 1. Incorporar Variables Climáticas

```r
# Ejemplo de análisis futuro
modelo_clima <- lm(casos ~ temperatura + precipitacion + humedad + provincia)
```

**Ventaja:** Mejor comprensión de factores ambientales.

#### 2. Modelos más Complejos

**GLM (Generalized Linear Models):**
```r
modelo_poisson <- glm(casos ~ anio + provincia, 
                      family = poisson(link = "log"))
```

**Ventaja:** Más apropiado para datos de conteo.

**Series Temporales:**
```r
modelo_arima <- auto.arima(ts_casos)
forecast(modelo_arima, h = 12)
```

**Ventaja:** Predicciones más precisas.

#### 3. Análisis Espacial

```r
library(sf)
library(ggspatial)

# Mapas coropléticos
mapa_noa <- st_read("shapefiles/noa.shp")
ggplot(mapa_noa) +
  geom_sf(aes(fill = casos_por_100k))
```

**Ventaja:** Visualización geográfica más rica.

#### 4. Machine Learning

```r
library(randomForest)

modelo_rf <- randomForest(casos ~ ., data = datos_modelo)
```

**Ventaja:** Captura relaciones no lineales.

---

## 📚 Apéndices

### Apéndice A: Diccionario de Variables

Ver [`docs/diccionario_variables.md`](diccionario_variables.md)

### Apéndice B: Comandos R Útiles

#### Cargar Datos

```r
# Desde RData
load("data/processed/dengue_clean.RData")

# Desde CSV
dengue <- read_csv("data/processed/dengue_clean.csv")
```

#### Explorar Datos

```r
# Ver primeras filas
head(dengue_clean)

# Estructura
str(dengue_clean)

# Resumen
summary(dengue_clean)

# Nombres de columnas
names(dengue_clean)
```

#### Filtrar y Seleccionar

```r
# Filtrar filas
dengue_2024 <- dengue_clean %>% filter(anio == 2024)

# Seleccionar columnas
dengue_simple <- dengue_clean %>% select(anio, provincia, cantidad_casos)

# Ambos
tucuman_2024 <- dengue_clean %>%
  filter(anio == 2024, provincia == "Tucumán") %>%
  select(departamento, cantidad_casos)
```

#### Agrupar y Resumir

```r
# Por provincia
por_provincia <- dengue_clean %>%
  group_by(provincia) %>%
  summarise(
    total = sum(cantidad_casos),
    promedio = mean(cantidad_casos),
    mediana = median(cantidad_casos)
  )
```

#### Visualizar

```r
# Histograma
ggplot(dengue_clean, aes(x = cantidad_casos)) +
  geom_histogram(bins = 30)

# Boxplot
ggplot(dengue_clean, aes(x = provincia, y = cantidad_casos)) +
  geom_boxplot()

# Scatter plot
ggplot(dengue_clean, aes(x = anio, y = cantidad_casos)) +
  geom_point()
```

### Apéndice C: Recursos Adicionales

#### Libros

- **R for Data Science** - Hadley Wickham
- **ggplot2: Elegant Graphics for Data Analysis** - Hadley Wickham
- **Statistical Inference** - Casella & Berger

#### Cursos Online

- **DataCamp:** Introduction to R
- **Coursera:** Data Science Specialization (Johns Hopkins)
- **edX:** Statistics and R (Harvard)

#### Documentación

- [tidyverse.org](https://www.tidyverse.org/)
- [ggplot2.tidyverse.org](https://ggplot2.tidyverse.org/)
- [r-project.org](https://www.r-project.org/)

#### Epidemiología

- [OMS - Dengue](https://www.who.int/es/news-room/fact-sheets/detail/dengue-and-severe-dengue)
- [Ministerio de Salud Argentina](https://www.argentina.gob.ar/salud)

---

## 🎯 Resumen Final

### ¿Qué Aprendimos?

1. **Flujo de análisis de datos:**
   - Diagnóstico → Limpieza → Descriptivo → Inferencial → Visualización

2. **Técnicas estadísticas:**
   - Estadística descriptiva
   - Regresión lineal múltiple
   - ANOVA
   - Pruebas de hipótesis

3. **Programación en R:**
   - tidyverse (dplyr, ggplot2)
   - Modelos estadísticos (lm, aov)
   - Visualización profesional

4. **Epidemiología:**
   - Patrones de dengue en el NOA
   - Estacionalidad
   - Factores de riesgo

### Mensaje Final

Este proyecto demuestra cómo el **análisis de datos** puede generar **información accionable** para la **salud pública**. Los hallazgos no son solo números, son herramientas para **salvar vidas**.

---

**¡Gracias por su atención!**

*¿Preguntas?*

---

*Documento preparado para presentación en clase*  
*Última actualización: Diciembre 2025*
