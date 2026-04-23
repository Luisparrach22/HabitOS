import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Cargar variables de entorno
dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

// Middleware
app.use(cors());
app.use(express.json());

// Ruta de prueba (Hello World)
app.get('/', (req, res) => {
  res.json({
    status: 'success',
    message: 'Hello World! El backend de HabitOS está funcionando correctamente 🚀'
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`✅ Servidor backend corriendo en el puerto ${PORT}`);
});
