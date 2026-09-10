# 📱 Roadmap y Suite de Ideas: "Mi Abuelito" (NonoCare)

Aplicación móvil colaborativa para el seguimiento médico, registro ágil de signos vitales y sincronización familiar en tiempo real para el cuidado de adultos mayores.

---

## 🎯 Objetivos Principales
1. **Cero Fricción para Anotar:** Registro en menos de 5 segundos de Glucosa, Orina (cc) y Presión Arterial con autoguardado.
2. **Conexión Familiar Instantánea:** Sincronización en vivo mediante un código corto único (ej. `A453`), sin requerir contraseñas complejas.
3. **Notificaciones Push en Vivo:** Cada vez que un familiar anota, todos reciben una notificación clara: *"Sofía agregó 120 azúcar a las 17:08"*.
4. **Modo Planilla Médica Digital:** Reemplazo directo y scrolleable del cuaderno o plantilla en papel que piden los médicos, diseñado para entregar el teléfono en la consulta médica y evaluar la evolución en 10 segundos.
5. **Monetización con Google AdMob:** Integración de Banners e Interstitials no intrusivos, lista para Google Play Store.

---

## 🗺️ Fases del Roadmap

### 🚀 Fase 1: MVP (Mínimo Producto Viable) - *Implementado en esta versión*
- [x] Conexión por ID familiar de 4 caracteres (ej. `A453`) o escaneo de QR.
- [x] Módulo de Carga Rápida con Autoguardado:
  - 🩸 **Glucosa / Azúcar:** mg/dL con selector de momento (ayunas, antes/después de comer, noche).
  - 💧 **Orina / Diuresis:** Volumen en cc / ml con botones de acceso rápido y opción de pañales.
  - 💓 **Presión Arterial:** Sistólica / Diastólica / Pulso con clasificación automática (OMS/AHA).
- [x] Notificaciones Push Familiares en tiempo real.
- [x] **Modo Planilla Médica Digital:** Vista de tabla/fichas scrolleable de alto contraste con semáforos clínicos (Verde/Amarillo/Rojo) y cabecera fija de promedios.
- [x] Filtros por período (Hoy, 7 días, 15 días, 30 días) y por franja horaria (Mañanas, Tardes, Noches).
- [x] Exportador de Informe Médico a PDF profesional imprimible y compartible por WhatsApp.
- [x] Integración de Google AdMob (Banners e Interstitials) con IDs de prueba listos para producción.

### 📈 Fase 2: Analítica y Personalización Avanzada
- [ ] Gráficos interactivos de dispersión glucosa vs. horarios de comida.
- [ ] Umbrales de alerta personalizados por patología (ej: metas especiales para diabéticos tipo 2 o hipertensos en tratamiento).
- [ ] Modo offline con sincronización en cola (Queue Sync) para zonas sin cobertura hospitalaria.

### 💊 Fase 3: Ecosistema Integral de Cuidado
- [ ] **Pastillero Digital Colaborativo:** Alarma familiar con botón "Ya se la di" para evitar duplicación de dosis entre cuidadores.
- [ ] **Balance Hídrico Automático:** Comparativa diaria de líquidos ingeridos vs. orina eliminada.
- [ ] **Widget de Escritorio Android:** Botones directos en la pantalla de inicio para cargar sin abrir la app.
- [ ] **Reconocimiento por Foto (OCR):** Detección automática de números al apuntar la cámara al tensiómetro o glucómetro.
