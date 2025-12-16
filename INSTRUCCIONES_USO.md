# Instrucciones de Uso - Archivos Unificados

## 📁 Archivos Creados

### 1. `analisis_dengue_clase.R` - Script para Clase
**Propósito**: Script único ejecutable línea por línea para presentaciones en clase.

**Características**:
- ✅ Instala automáticamente todas las librerías necesarias
- ✅ Comentarios extensos en español explicando cada paso
- ✅ Muestra gráficos en pantalla (NO los guarda como archivos)
- ✅ Incluye interpretaciones epidemiológicas de cada resultado
- ✅ Ejecuta todo el análisis de principio a fin

**Cómo usar**:
```r
# Opción 1: Ejecutar todo el script de una vez
source("analisis_dengue_clase.R")

# Opción 2: Ejecutar línea por línea en RStudio (RECOMENDADO PARA CLASE)
# - Abrir el archivo en RStudio
# - Seleccionar líneas y presionar Ctrl+Enter (Windows) o Cmd+Enter (Mac)
# - Ir explicando cada sección mientras se ejecuta
```

---

### 2. `dashboard_dengue.Rmd` - Dashboard HTML Interactivo
**Propósito**: Generar un dashboard HTML profesional con gráficos interactivos.

**Características**:
- ✅ Dashboard con 6 pestañas temáticas
- ✅ Gráficos interactivos con Plotly (zoom, hover, etc.)
- ✅ Tablas filtrables y buscables
- ✅ Diseño profesional con tema Cosmo
- ✅ Se puede compartir como un solo archivo HTML

**Cómo generar el HTML**:

#### Paso 1: Instalar librerías adicionales
```r
install.packages("flexdashboard")
install.packages("plotly")
install.packages("DT")
install.packages("shiny")
```

#### Paso 2: Generar el dashboard
```r
# Opción A: Desde R
rmarkdown::render("dashboard_dengue.Rmd")

# Opción B: Desde RStudio
# - Abrir dashboard_dengue.Rmd
# - Hacer clic en el botón "Knit" (o presionar Ctrl+Shift+K)
```

#### Paso 3: Ver el resultado
El archivo `dashboard_dengue.html` se generará en la misma carpeta.
Ábrelo con cualquier navegador web (Chrome, Firefox, Edge, etc.)

---

## 🎯 Diferencias Entre Ambos Archivos

| Característica | `analisis_dengue_clase.R` | `dashboard_dengue.Rmd` |
|----------------|---------------------------|------------------------|
| **Formato** | Script R (.R) | R Markdown (.Rmd) |
| **Salida** | Gráficos en pantalla | Archivo HTML |
| **Uso** | Explicar paso a paso en clase | Presentación final / Entrega |
| **Interactividad** | No | Sí (gráficos interactivos) |
| **Guarda archivos** | No | Sí (un HTML) |
| **Comentarios** | Muy extensos | Integrados en el documento |

---

## 📊 Contenido del Análisis

Ambos archivos incluyen:

1. **Configuración e instalación de paquetes**
2. **Carga y diagnóstico de datos**
3. **Limpieza y preprocesamiento**
4. **Análisis descriptivo**:
   - Evolución temporal
   - Distribución geográfica
   - Estacionalidad
   - Grupos etarios
5. **Análisis inferencial**:
   - Modelos de regresión
   - ANOVA
   - Pruebas de hipótesis
6. **Visualizaciones avanzadas**
7. **Conclusiones y recomendaciones**

---

## 💡 Recomendaciones de Uso

### Para Clase:
1. Usar `analisis_dengue_clase.R`
2. Ejecutar sección por sección
3. Explicar cada gráfico mientras aparece en pantalla
4. Pausar para discutir interpretaciones

### Para Entrega/Presentación Final:
1. Generar el HTML con `dashboard_dengue.Rmd`
2. Compartir el archivo HTML generado
3. El profesor puede explorar interactivamente los datos
4. Se puede proyectar en clase para mostrar resultados

### Para Ambos:
- Asegúrate de que el archivo `dengue_2018_2025.xlsx` esté en la misma carpeta
- La primera ejecución puede tardar más (instalación de paquetes)
- Ejecuciones posteriores serán más rápidas

---

## ⚠️ Solución de Problemas

### Error: "No se encuentra el archivo dengue_2018_2025.xlsx"
**Solución**: Asegúrate de que el archivo Excel esté en la misma carpeta que los scripts.

### Error al instalar paquetes
**Solución**: 
```r
# Ejecutar esto primero
install.packages(c("tidyverse", "readxl", "plotly", "flexdashboard", "DT"))
```

### El dashboard no se genera
**Solución**:
```r
# Instalar rmarkdown si no está instalado
install.packages("rmarkdown")

# Luego intentar de nuevo
rmarkdown::render("dashboard_dengue.Rmd")
```

---

## 📝 Notas Importantes

1. **Estructura del proyecto**: Los archivos originales en la carpeta `R/` se mantienen intactos. Estos nuevos archivos son complementarios.

2. **Sin guardar archivos intermedios**: El script de clase NO guarda imágenes ni archivos. Todo se muestra en pantalla. Si quieres guardar resultados, usa los scripts originales del proyecto.

3. **Actualización de datos**: Si actualizas el archivo Excel, solo necesitas volver a ejecutar los scripts.

---

## 🎓 Sugerencia para Presentación en Clase

**Flujo recomendado**:

1. **Inicio**: Mostrar el dashboard HTML proyectado (5 min)
   - Da una vista general rápida del análisis completo
   
2. **Desarrollo**: Ejecutar `analisis_dengue_clase.R` paso a paso (30-40 min)
   - Explicar cada sección mientras se ejecuta
   - Discutir interpretaciones con la clase
   
3. **Cierre**: Volver al dashboard HTML (5 min)
   - Permitir que el profesor explore interactivamente
   - Responder preguntas específicas usando los filtros del dashboard

---

¿Necesitas ayuda? Revisa los comentarios dentro de cada archivo para más detalles.
