import express, { Express, Request, Response } from "express";
import cors from "cors";
import bodyParser from "body-parser";
import "dotenv/config.js";
import authRoutes from "./routes/auth.js";
import medicationRoutes from "./routes/medications.js";
import { query as dbQuery } from "./database/db.js";

const app: Express = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(
  cors({
    origin: "*",
    credentials: false,
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);
app.use(bodyParser.json({ limit: "50mb" }));
app.use(bodyParser.urlencoded({ extended: true, limit: "50mb" }));

// Request logging middleware - log all incoming requests
app.use((req: Request, res: Response, next) => {
  const timestamp = new Date().toISOString();
  console.log(`\n[${timestamp}] 📨 ${req.method} ${req.path}`);
  console.log(`   Remote: ${req.ip || "unknown"}`);
  if (Object.keys(req.body).length > 0) {
    console.log(`   Body:`, JSON.stringify(req.body, null, 2));
  }
  next();
});

// Health check
app.get("/health", (req: Request, res: Response) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/medications", medicationRoutes);

// 404 handler
app.use((req: Request, res: Response) => {
  console.log(`   ❌ 404 Not Found: ${req.method} ${req.path}`);
  res.status(404).json({ error: "Not Found" });
});

// Error handler
app.use((err: any, req: Request, res: Response) => {
  console.error(`   ⚠️  Error:`, err);
  res.status(err.status || 500).json({
    error: err.message || "Internal Server Error",
  });
});

// Database initialization
const initializeDatabase = async () => {
  try {
    // Check if tables exist
    const result = await dbQuery(
      `SELECT EXISTS(
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'users'
      )`
    );

    if (!result.rows[0].exists) {
      console.log("Database tables not found. Creating schema...");
      // We'll handle schema creation manually
      console.log(
        "Please run: psql -U medicycle -d medicycle_db -f src/database/schema.sql"
      );
    } else {
      console.log("Database tables found.");
    }
  } catch (error) {
    console.error("Database initialization error:", error);
  }
};

// Start server
const startServer = async () => {
  try {
    await initializeDatabase();

    app.listen(port, () => {
      console.log(`
╔════════════════════════════════════════╗
║     MediCycle API Server Running       ║
║                                        ║
║  🌐 Server: http://localhost:${port}      ║
║  📦 Environment: ${process.env.NODE_ENV || "development"}        ║
║                                        ║
╚════════════════════════════════════════╝
      `);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

startServer();

export default app;
