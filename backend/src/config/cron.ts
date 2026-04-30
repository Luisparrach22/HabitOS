import cron from 'node-cron';
import { processEndOfDayShields } from '../services/shield.service.js';

/**
 * Configura todos los cron jobs del sistema.
 *
 * Shield Cron: Se ejecuta cada hora en punto.
 * Internamente, solo procesa usuarios cuya hora local sea 23:XX,
 * así respetamos la timezone de cada usuario.
 */
export function setupCronJobs(): void {
  // Cada hora en punto: "0 * * * *"
  cron.schedule('0 * * * *', async () => {
    console.log(`\n⏰ [CRON] Ejecutando verificación de shields — ${new Date().toISOString()}`);
    try {
      const result = await processEndOfDayShields();
      console.log(`✅ [CRON] Shields procesados:`, result);
    } catch (error) {
      console.error('❌ [CRON] Error en processEndOfDayShields:', error);
    }
  });

  console.log('🕐 Cron jobs configurados (shield check cada hora).');
}
