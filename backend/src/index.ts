import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Cargar variables de entorno
dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

import routes from './routes';

// Middleware
app.use(cors());
app.use(express.json());

// Rutas
app.use('/', routes);

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`✅ Servidor backend corriendo en el puerto ${PORT}`);
});
