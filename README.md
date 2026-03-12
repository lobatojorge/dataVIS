# Data Visualization

En este repositorio recojo una infraestructura completa diseñada para procesar, auditar y visualizar los datos históricos de las radiales oceanográficas del Instituto Español de Oceanografía (IEO)

El objetivo principal es pasar de tener Excels estáticos a un **Sistema de Apoyo a la Decisión (DSS)** interactivo, replicando y escalando los estándares del ICES (como el modelo ATAC del WGINOR) y aplicando principios de Oceanic Data Architecture

## 

En lugar de tener un "código espagueti" que haga todo a la vez y reviente por cualquier lado, el sistema está troceado en especialistas (agentes):

1. **Ingesta:** Traga los Excels crudos del IEO, estandariza nombres, limpia los formatos de fecha y prepara el terreno. Los datos crudos **nunca** se tocan
2. **El Auditor Forense (Data Observability):** Antes de graficar, empleamos Machine Learning no supervisado (`IsolationForest`) para detectar inconsistencias en los datos (temperaturas imposibles, picos irreales) y genera un reporte de calidad que ayuda al investigador a tomar decisiones sobre el futuro modelado
3. **Forecasting:** Un motor predictivo para series temporales que calcula la tendencia y el pronóstico de los próximos años con sus respectivos intervalos de confianza. Basado en la metodología del WGINOR
4. **El Escaparate (Streamlit DSS):** Un dashboard interactivo donde el usuario puede explorar los datos

## Stack Tecnológico

* **Core & Datos:** Python, Pandas, Pathlib (eliminación de rutas absolutas para mejorar la reproducibilidad)
* **Machine Learning:** Scikit-learn (Isolation Forest) y modelos de Forecasting
* **Frontend interactivo:** Streamlit + Plotly


## 🚀 Cómo ejecutarlo

Clona el repo y desde la cmd:

1. **Instala las dependencias:**
   ```bash
   pip install -r requirements.txt
---
2. Ejecuta el pipeline interno:
Esto procesa los datos crudos, pasa la auditoría forense y genera los resultados predictivos
```bash
python main.py
```
3. Levanta la interfaz web:
```bash
streamlit run app.py
```

## Licencia

Este proyecto está bajo la **Licencia MIT**. Ver [LICENSE](LICENSE) para más detalles.

**Autor:** Jorge Lobato · 2026
