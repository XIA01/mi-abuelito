# 👴 Mi Abuelito — Control de Salud Familiar

> App web y móvil colaborativa para el registro de signos vitales de adultos mayores.

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

---

## 🌟 ¿Qué es?

**Mi Abuelito** es una Progressive Web App (PWA) hecha con Flutter que permite a toda la familia registrar y visualizar los signos vitales del abuelo/a desde cualquier celular, en tiempo real y sin necesidad de crear una cuenta.

**¿Por qué?** Porque las familias que cuidan a un adulto mayor necesitan una herramienta simple, colaborativa y en español.

## ✨ Funcionalidades

- 🩸 **Glucosa** — fasting, antes/después de comer, nocturna
- 💓 **Presión arterial** — sistólica, diastólica y pulso
- 💧 **Orina** — volumen, aspecto y control de pañal
- 📅 **Registro con fecha histórica** — para cuando no tenías el celular
- 🩺 **Planilla médica digital** — para llevar al médico
- 📄 **Exportar PDF** del historial completo
- 👨‍👩‍👧 **Código familiar** — compartís un código y toda la familia registra desde sus celulares
- ☁️ **Sincronización en tiempo real** con Firebase Firestore
- 🔄 **Auto-desconexión** — si alguien borra la ficha, se actualiza en todos los celulares
- 📱 **PWA** — se instala en el celular como una app nativa

## 🛠️ Stack

| Capa | Tecnología |
|------|------------|
| Framework | Flutter 3.47+ (Web + Android) |
| Base de datos | Firebase Firestore (en la nube) + SharedPreferences (local) |
| Estado | Provider |
| PDF | `pdf` + `printing` |
| Hosting | Vercel (gratis) |

## 🚀 Demo en vivo

👉 [mi-abuelito.vercel.app](https://mi-abuelito.vercel.app)

## 🏁 Cómo correrlo localmente

### Prerequisitos
- Flutter SDK 3.x
- Una cuenta en [Firebase](https://console.firebase.google.com) (gratis)

### Pasos

1. Clonar el repo:
   ```bash
   git clone https://github.com/XIA01/mi-abuelito.git
   cd mi-abuelito
   ```

2. Instalar dependencias:
   ```bash
   flutter pub get
   ```

3. Configurar Firebase:
   - Creá un proyecto en [Firebase Console](https://console.firebase.google.com)
   - Habilitá **Firestore Database** en modo de prueba
   - Creá una app Web en tu proyecto de Firebase
   - Copiá las credenciales en `lib/firebase_options.dart`:
   ```dart
   // Usá el archivo firebase_options.example.dart como plantilla
   ```

4. Correr en el navegador:
   ```bash
   flutter run -d chrome
   ```

5. Build web para producción:
   ```bash
   flutter build web --release
   # El resultado queda en build/web/. Para compilar y publicar en Vercel de una vez:
   # doble clic en publicar_web.bat (la primera vez: npx vercel login)
   ```

## 🔐 Seguridad y privacidad

- **No hay cuentas de usuario ni contraseñas** — todo el acceso es por código corto familiar.
- Los datos se guardan en tu propia instancia de Firebase (vos sos el dueño).
- No hay tracking de usuarios, analytics propios ni venta de datos.
- Los datos médicos nunca salen de tu Firebase.

## 📁 Estructura del proyecto

```
lib/
├── main.dart                    # Punto de entrada + init Firebase
├── firebase_options.dart        # ⚠️ No incluida — creala vos (ver arriba)
├── models/
│   ├── vital_sign.dart          # Modelo de registro
│   └── patient_profile.dart     # Perfil del abuelo
├── providers/
│   └── patient_provider.dart    # Estado global (Provider)
├── services/
│   ├── database_service.dart    # Firestore + SharedPreferences
│   ├── ad_service.dart          # AdMob (opcional)
│   ├── notification_service.dart
│   └── pdf_report_service.dart  # Generación de PDF
├── screens/
│   ├── welcome_screen.dart
│   ├── home_dashboard_screen.dart
│   ├── log_vital_screen.dart
│   └── doctor_sheet_screen.dart
└── widgets/
    ├── ad_banner_widget.dart
    ├── flag_counter_widget.dart
    ├── doctor_summary_header.dart
    └── doctor_table_row.dart
```

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Si tenés una idea o encontraste un bug:

1. Hacé un fork
2. Creá tu rama (`git checkout -b feature/nueva-funcionalidad`)
3. Hacé commit de tus cambios
4. Abrí un Pull Request

## ❤️ Apoyar el proyecto

Si la app te resulta útil y querés apoyar el desarrollo, podés invitar un café al Alias de Mercado Pago: **`b1.66er`**

## 📄 Licencia

MIT — libre para usar, modificar y distribuir.
