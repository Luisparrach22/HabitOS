import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/auth.routes.js';
import habitRoutes from './routes/habit.routes.js';
import healthRoutes from './routes/index.js';
import { setupCronJobs } from './config/cron.js';

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware global
app.use(cors());
app.use(express.json());

// Rutas
app.use('/api/health', healthRoutes);
app.use('/api/auth', authRoutes);
app.use('/api', habitRoutes);

// Iniciar cron jobs
setupCronJobs();

app.listen(port, () => {
  console.log(`\n🚀 Backend HabitOS corriendo en puerto ${port}`);
  console.log(`   Health: http://localhost:${port}/api/health`);
  console.log(`   Auth:   http://localhost:${port}/api/auth/login`);
  console.log(`   Habits: http://localhost:${port}/api/habits\n`);
});
