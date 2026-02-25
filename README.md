# rap+ia · RAP con IA para Auditoría de Datos Marinos

[![R](https://img.shields.io/badge/R-276DC3?style=flat-square&logo=r&logoColor=white)](https://www.r-project.org/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![Quarto](https://img.shields.io/badge/Quarto-1971B2?style=flat-square&logo=quarto&logoColor=white)](https://quarto.org/)

**Reproducible Analytical Pipeline** que combina **R**, **Python** (scikit-learn) y **Quarto** para la auditoría forense y visualización de series temporales de ecología marina mediante detección de anomalías con **Isolation Forest**.

---

## Problema

Las series temporales de datos marinos (temperatura, salinidad, nutrientes, biomasa, etc.) suelen contener **ruido, valores aberrantes y anomalías** que distorsionan análisis y decisiones. Revisar manualmente millones de registros no es viable y retrasa la publicación de indicadores fiables.

## Solución

- **Auditoría forense automatizada** con modelos de **Inteligencia Artificial** (Isolation Forest) para marcar y priorizar anomalías en los datos.
- **Dashboard interactivo** generado con Quarto que permite explorar series, diagnósticos por variable y resultados de la auditoría.
- Pipeline **reproducible** (R + Python + Quarto) listo para integrarse en flujos de calidad de datos del IEO.

---

## Estructura del proyecto

```
rap+ia/
├── dashboard/           # Aplicación Quarto (dashboard interactivo)
│   └── index.qmd
├── scripts/             # Pipeline: ingesta, auditoría ML y modelos
│   ├── 01_ingest.R
│   ├── 02_audit_ml.qmd  # Auditoría con Isolation Forest (R + Python)
│   └── 03_models.R
├── data/                # Datos crudos y procesados (no versionados)
│   ├── raw/
│   └── processed/
├── docs/                # Salida renderizada del sitio/dashboard Quarto
│   └── ...
├── .gitignore
├── LICENSE
└── README.md
```

---

## Requisitos

- **R** (≥ 4.x) con paquetes: `tidyverse`, `reticulate`, `knitr`, `bslib`, `plotly`, `reactable`, etc.
- **Python** (3.x) con `scikit-learn`, `pandas`, `numpy` (recomendado: entorno `r-reticulate` para uso desde R).
- **Quarto** CLI para renderizar reportes y dashboard.

## Uso

1. Colocar datos de entrada en `data/raw/` (o ajustar rutas en `scripts/01_ingest.R`).
2. Ejecutar en orden: `01_ingest.R` → `02_audit_ml.qmd` → `03_models.R`.
3. Renderizar el dashboard: desde la raíz, `quarto render dashboard/` o publicar en `docs/`.

---

## Licencia

Este proyecto está bajo la **Licencia MIT**. Ver [LICENSE](LICENSE) para más detalles.

**Autor:** Jorge Lobato · 2026
