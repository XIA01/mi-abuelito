# 🩺 Arquitectura Técnica y Modo Planilla Médica Digital

Este documento detalla la estructura de datos, los criterios clínicos aplicados para los semáforos médicos y el diseño de la pantalla de entrega en mano al doctor.

---

## 🩺 Criterios Clínicos para Semáforos Médicos

La aplicación implementa las guías de la **American Diabetes Association (ADA)** y del **American College of Cardiology / American Heart Association (ACC/AHA)**:

### 1. Glucosa en Sangre (mg/dL)
* 🟢 **Normal (En Rango):**
  * En Ayunas / Antes de comer: `70 - 130 mg/dL`
  * Postprandial (2 horas después de comer): `< 180 mg/dL`
* 🟡 **Elevada (Precaución):**
  * En Ayunas: `131 - 160 mg/dL`
  * Postprandial: `181 - 220 mg/dL`
* 🔴 **Alerta / Crítico:**
  * Hipoglucemia: `< 70 mg/dL` (Alerta urgente de hipoglucemia)
  * Hiperglucemia severa: `> 220 mg/dL`

### 2. Presión Arterial (mmHg)
* 🟢 **Normal:** Sistólica `< 120` y Diastólica `< 80`
* 🟡 **Elevada:** Sistólica `120 - 129` y Diastólica `< 80`
* 🟠 **Hipertensión Grado 1:** Sistólica `130 - 139` o Diastólica `80 - 89`
* 🔴 **Hipertensión Grado 2:** Sistólica `>= 140` o Diastólica `>= 90`
* 🚨 **Crisis Hipertensiva:** Sistólica `> 180` y/o Diastólica `> 120` (Alerta visual prioritaria)

### 3. Orina / Balance Hídrico (cc o ml)
* Registra el volumen por micción (ej: `250 cc`, `500 cc`, `900 cc`) o estado de pañal.
* Calcula la diuresis acumulada en 24 horas para control de retención o deshidratación.

---

## 📋 Especificaciones de la "Planilla Médica Digital" (Doctor View)

Cuando se activa el **Modo Doctor** en la app:
1. **Header Fijo Superior (Sticky):** Muestra el nombre del paciente, edad, ID (`A453`), y los **promedios del período seleccionado** (Glucosa promedio, Presión arterial promedio, Volumen diario promedio de orina).
2. **Selector de Franja y Rango:** Chips rápidos para filtrar por:
   - *[Últimos 7 días]* | *[Últimos 15 días]* | *[Este Mes]*
   - *[Todas las tomas]* | *[En Ayunas / Mañana]* | *[Tarde]* | *[Noche]*
3. **Filas de Alto Contraste:** Cada fila representa una medición con:
   - Fecha y Hora exacta (ej. *30 Ago - 17:08*).
   - Chip de franja horaria.
   - Valor medido en fuente grande y legible.
   - Badge con semáforo clínico (*"Normal"*, *"Elevada"*, *"Alerta"*).
   - Nombre de quién realizó la medición (*"Sofía (Nieta)"*).
4. **Exportar a PDF:** Un toque genera un documento PDF formal listo para imprimir o enviar por WhatsApp al especialista.
