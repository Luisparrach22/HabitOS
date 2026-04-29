import express from 'express';
import cors from 'cors';
import habitRoutes from './routes/habit.routes.js';

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api', habitRoutes);

app.listen(port, () => {
  console.log(`Backend server is running on port ${port}`);
});
