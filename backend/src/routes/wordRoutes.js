/**
 * Vocabulary Routes
 * Defines API routing paths.
 */
const express = require('express');
const router = express.Router();
const wordController = require('../controllers/wordController');

// Map GET / to controller
router.get('/', wordController.getWords);

module.exports = router;
