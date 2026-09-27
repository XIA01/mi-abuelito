@echo off
REM Compila la version web de Mi Abuelito y la publica en Vercel (https://mi-abuelito.vercel.app).
REM La primera vez: npx vercel login
setlocal
cd /d "%~dp0"

echo [1/3] Compilando la version web...
call flutter build web --release || goto :error

echo [2/3] Vinculando con el proyecto de Vercel...
cd build\web
call npx -y vercel link --yes --project mi-abuelito >nul || goto :error
REM "vercel link" deja un token temporal en .env.local: nunca debe publicarse
del /q .env.local .gitignore 2>nul
(echo .vercel& echo .env*)> .vercelignore

echo [3/3] Publicando...
call npx -y vercel deploy --prod --yes || goto :error
echo.
echo Listo: https://mi-abuelito.vercel.app
goto :eof

:error
echo.
echo Hubo un error. Revisa el mensaje de arriba.
exit /b 1
