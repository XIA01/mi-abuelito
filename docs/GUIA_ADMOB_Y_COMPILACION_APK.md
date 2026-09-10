# 💰 Guía de Google AdMob, Compilación de APK y Publicación en Google Play Store

Esta guía contiene los pasos exactos para configurar los anuncios de Google AdMob, generar el instalador APK / App Bundle (.aab) y subirlo a tu cuenta de Google Play Console.

---

## 1. Configuración de Google AdMob

La app ya viene configurada por defecto con los **IDs de prueba oficiales de Google** para que puedas compilar y probar inmediatamente sin riesgo de baneo por clics propios.

### A. IDs de Prueba (Actualmente en el código):
- **App ID (AndroidManifest.xml):** `ca-app-pub-3940256099942544~3347511713`
- **Banner Ad Unit ID:** `ca-app-pub-3940256099942544/6300978111`
- **Interstitial Ad Unit ID:** `ca-app-pub-3940256099942544/1033173712`

### B. Para pasar a Producción (Tus propios anuncios):
1. Ingresa en [Google AdMob Console](https://apps.admob.com/).
2. Haz clic en **Apps > Agregar App** (Plataforma: Android).
3. Copia tu **App ID** de AdMob y reemplázalo en `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-XXXXXXXXXXXXX~XXXXXXXXXX"/>
   ```
4. Crea dos bloques de anuncios en AdMob:
   - 1 Bloque tipo **Banner** (Copia el ID).
   - 1 Bloque tipo **Intersticial** (Copia el ID).
5. Pégalos en el archivo `lib/services/ad_service.dart` en las constantes de producción:
   ```dart
   static const String prodBannerId = 'ca-app-pub-XXXXXXXX/YYYYYYYY';
   static const String prodInterstitialId = 'ca-app-pub-XXXXXXXX/ZZZZZZZZ';
   ```

---

## 2. Compilación del APK para Probar en tu Teléfono

Para generar el archivo `.apk` instalable de forma directa en cualquier dispositivo Android:

```bash
# 1. Obtener dependencias
flutter pub get

# 2. Compilar APK en modo Release (optimizado)
flutter build apk --release
```

El archivo generado estará ubicado en:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 3. Generación del Android App Bundle (.aab) para Google Play Console

Google Play Store exige el formato `.aab` para subir nuevas aplicaciones a la tienda:

### Paso 1: Generar la llave de firma (Keystore)
Ejecuta en tu terminal:
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Paso 2: Crear el archivo `android/key.properties`
Crea el archivo con tus contraseñas:
```properties
storePassword=tu_password
keyPassword=tu_password
keyAlias=upload
storeFile=../upload-keystore.jks
```

### Paso 3: Compilar el App Bundle
```bash
flutter build appbundle --release
```
El archivo se generará en:
`build/app/outputs/bundle/release/app-release.aab`

---

## 4. Subir a Google Play Console

1. Entra a [Google Play Console](https://play.google.com/console).
2. Haz clic en **Crear App**:
   - Nombre: **Mi Abuelito - Salud y Cuidados**
   - Idioma predeterminado: Español.
   - Tipo: Aplicación > Gratis.
   - Declaración de anuncios: Marca **"Sí, mi app contiene anuncios"**.
3. En la sección **Producción** o **Pruebas cerradas**, sube el archivo `app-release.aab`.
4. Completa la ficha de la tienda (capturas de pantalla, descripción y política de privacidad).
5. ¡Enviar a revisión!
