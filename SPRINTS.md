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

### 🟢 Sprint 11: Personalización Estética y Temas (Completado)
* **Objetivo:** Permitir al usuario cambiar la interfaz visual de la app y desbloquear opciones avanzadas.
* **Componentes:**
  * **Selector de Temas:** Opciones en perfil/configuración para cambiar entre Modo Oscuro, Modo Claro y Sincronización con el sistema (`Theme.swift`).
  * **Temas Premium (Pro):** Temas de color globales (*Cyberpunk*, *Minimal Dark*, *Sunset Warm*) que alteran dinámicamente fondos y acentos.
  * **Icono de la App Alternativo:** Cambio de icono de la aplicación en tiempo de ejecución para usuarios Pro (`setAlternateIconName`).

### 🟢 Sprint 12: Portabilidad de Datos (CSV/JSON Export) (Completado)
* **Objetivo:** Ofrecer exportación e importación de datos al usuario.
* **Componentes:**
  * **Exportador de Datos:** Servicio `DataPortabilityService.swift` que serializa `User`, `Habit`, `HabitLog` y `ShieldUsage` a JSON (completo) y CSV (para hojas de cálculo).
  * **Interfaz de Importación/Exportación:** Integración con `fileExporter` y `fileImporter` en `ProfileView.swift`.

### 🟢 Sprint 13: Autenticación e Identidad (Completado)
* **Objetivo:** Sistema de cuentas y gestión de sesiones de usuario.
* **Componentes:**
  * **Vistas de Autenticación:** Vistas nativas `LoginView.swift`, `RegisterView.swift` y `ForgotPasswordView.swift` en `Views/Auth`.
  * **Servicio de Autenticación:** `AuthService.swift` con hashing seguro SHA-256 (CryptoKit), inicio y cierre de sesión persistiéndose en `SwiftData`.

### 🟢 Sprint 14: Widgets de Pantalla de Inicio Avanzados (Completado)
* **Objetivo:** Expandir la variedad de widgets en la pantalla de inicio de iOS.
* **Componentes:**
  * **Widget de Racha Semanal:** `WeeklyStreakWidget.swift` para visualización de los últimos 7 días.
  * **Widget de Gamificación:** `GamificationWidget.swift` que muestra el nivel, barra de XP y escudos disponibles.
  * **Widgets Adicionales:** `HabitStreakWidget.swift`, `HabitDailyWidget.swift` y `HabitQuickAddWidget.swift`.

---

## 🚀 Backlog de Sprints Pendientes

> [!NOTE]
> Todos los sprints planificados actualmente en el roadmap han sido completados exitosamente.
