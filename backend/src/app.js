/**
 * App Entry Point
 * Sets up Express app, middleware, routes, and starts listening.
 */
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const morgan = require('morgan');
require('dotenv').config();

const wordRoutes = require('./routes/wordRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Security Middleware
app.use(helmet());

// Logging
app.use(morgan('dev'));

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: { message: "Too many requests, please try again later." }
});
app.use('/words', limiter);

// Compression Middleware
app.use(compression());

// Enable CORS so the Flutter app can access it from local network/localhost
app.use(cors());

// Parse JSON and URL-encoded bodies
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Log requests
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// Register routes
app.use('/words', wordRoutes);

// Root path fallback
app.get('/', (req, res) => {
  res.status(200).json({
    message: "LingoBreeze Backend API is running!",
    endpoints: {
      get_words: "/words (GET)"
    }
  });
});

// 404 Route handler
app.use((req, res, next) => {
  const error = new Error(`Not Found - ${req.originalUrl}`);
  res.status(404);
  next(error);
});

// Global Error Middleware
app.use((err, req, res, next) => {
  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  console.error(`Error: ${err.message}`);
  res.status(statusCode).json({
    message: err.message,
    stack: process.env.NODE_ENV === 'production' ? null : err.stack
  });
});

// Listen
app.listen(PORT, () => {
  console.log(`=============================================`);
  console.log(`  LingoBreeze API server started successfully!`);
  console.log(`  Running on: http://localhost:${PORT}`);
  console.log(`=============================================`);
});

module.exports = app;
