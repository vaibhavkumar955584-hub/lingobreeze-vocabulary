const wordService = require('../services/wordService');

/**
 * GET /words
 * Supports pagination via ?page=1&limit=10
 */
const getWords = (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    // Artificial delay for UX testing
    setTimeout(() => {
      try {
        const allWords = wordService.getMockWords();

        // Simple pagination logic
        const startIndex = (page - 1) * limit;
        const endIndex = page * limit;
        const results = allWords.slice(startIndex, endIndex);

        res.status(200).json({
          page,
          limit,
          total: allWords.length,
          data: results
        });
      } catch (err) {
        next(err);
      }
    }, 800);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getWords
};
