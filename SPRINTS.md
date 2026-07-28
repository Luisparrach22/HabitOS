# Roadmap y Backlog de Sprints — HabitOS

Este documento sirve como hoja de ruta (roadmap) para el desarrollo nativo de **HabitOS** en iOS y watchOS. Contiene el historial de sprints completados recientemente y la planificación de los próximos sprints pendientes.

---

## 📈 Historial de Sprints Recientes

### 🟢 Sprint 2: Core Visual & Vistas SwiftUI (Completado)
* **Objetivo:** Inicializar la arquitectura Swift nativa y recrear la interfaz modular.
* **Componentes:**
  * Estructura de directorios nativa y sistema de tipografía/colores (`Outfit` font y colores HIG).
  * Vistas: `OnboardingView` (carrusel + hábitos semilla), `DashboardView` (Mi Día), `CreateHabitView` (formulario + picker de iconos/colores), `HabitDetailView` (modal).

### 🟢 Sprint 8: iCloud Sync & Widgets (Completado)
* **Objetivo:** Persistencia avanzada en la nube y widget interactivo para la pantalla de inicio.
* **Componentes:**
  * Sincronización automática mediante **CloudKit** sobre el contenedor compartido de **SwiftData**.
  * Configuración de **App Groups** (`group.con.habitos.HabitOS`) para compartir la base de datos entre la App y la extensión del Widget.
  * Implementación de Widget diario interactivo utilizando `AppIntents` (`ToggleHabitIntent.swift`).

### 🟢 Sprint 9: Companion App para Apple Watch (Completado)
* **Objetivo:** Aplicación nativa independiente para watchOS sincronizada en tiempo real.
* **Componentes:**
  * Vistas optimizadas para la pantalla táctil reducida del reloj (`WatchDashboardView.swift`).
  * Conexión a la base de datos de SwiftData y sincronización invisible vía iCloud.
  * Respuesta háptica (`sensoryFeedback`) premium al completar tareas desde el Apple Watch.

### 🟢 Sprint 8 Pulido: Dinamización & Heatmap (Completado)
* **Objetivo:** Completar funciones secundarias del perfil y añadir visualización avanzada de datos.
* **Componentes:**
  * Integración del **MonthHeatmapGrid** (calendario mensual tipo GitHub) utilizando Swift Charts en la vista de estadísticas (`StatsView.swift`).
  * Edición del perfil de usuario (nombre y correo electrónico) y toggle funcional de notificaciones locales.

### 🟢 Sprint 10: Suscripción Pro y Monetización (StoreKit 2) (Completado)
* **Objetivo:** Implementar modelo de monetización premium y control de límites Pro.
* **Componentes:**
  - Configuración de `HabitOS.storekit` para pruebas de compras locales.
  - Servicio `StoreManager.swift` con StoreKit 2 y sincronización de estado `isPro` en SwiftData.
  - Pantalla premium y animada `PaywallView.swift` con beneficios detallados.
  - Limitación de hasta 5 hábitos para usuarios básicos.
  - Bloqueo y desenfoque del Heatmap en estadísticas y 6 colores exclusivos para usuarios Pro.

---

## 🚀 Backlog de Sprints Pendientes

> [!NOTE]
> Los siguientes sprints están planificados para ser ejecutados a continuación. Puedes elegir cualquiera de ellos para comenzar a trabajar.

### 🎨 Sprint 11: Personalización Estética y Temas
* **Descripción:** Permitir al usuario cambiar la interfaz visual de la app y desbloquear opciones avanzadas.
* **Lista de Tareas:**
  * [ ] **Selector de Temas:** Añadir la opción en configuración para cambiar el tema de la aplicación (Modo Oscuro, Modo Claro, o sincronización con el sistema).
  * [ ] **Temas Premium (Pro):** Crear al menos 3 temas de color globales (ej. *Cyberpunk*, *Minimal Dark*, *Sunset Warm*) que alteren los fondos y acentos principales.
  * [ ] **Icono de la App Alternativo:** Permitir a usuarios premium cambiar el icono de la app en la pantalla de inicio del dispositivo.

### 💾 Sprint 12: Portabilidad de Datos (CSV/JSON Export)
* **Descripción:** Ofrecer exportación y control de datos al usuario (función Pro).
* **Lista de Tareas:**
  * [ ] **Exportador de Datos:** Crear un servicio que serialice todos los datos locales de `User`, `Habit` y `HabitLog` a archivos estándar (JSON o CSV).
  * [ ] **Interfaz para Guardar:** Integrar `ShareLink` o `UIDocumentPickerViewController` para que el usuario guarde el archivo exportado en su app Archivos (Files) o lo envíe por correo.

### 🔐 Sprint 13: Autenticación e Identidad
* **Descripción:** Implementar sistema de cuentas propio si la sincronización silenciosa de CloudKit no es suficiente para futuras integraciones.
* **Lista de Tareas:**
  * [ ] **Vistas de Autenticación:** Diseñar la UI en la carpeta vacía `/Views/Auth` para Login, Registro y Recuperación de Contraseña.
  * [ ] **Sincronización:** Acoplar la sincronización a un backend remoto si la aplicación se vuelve multiplataforma.

### 📱 Sprint 14: Widgets de Pantalla de Inicio Avanzados
* **Descripción:** Expandir la presencia de la app en el dispositivo del usuario con más variedad de widgets.
* **Lista de Tareas:**
  * [ ] **Widget de Racha Semanal:** Mostrar un gráfico visual del progreso de los últimos 7 días de un hábito en específico directamente en la pantalla de inicio.
  * [ ] **Widget de Gamificación:** Mostrar el nivel actual del usuario, barra de XP y número de escudos disponibles en formato de widget pequeño/mediano.
