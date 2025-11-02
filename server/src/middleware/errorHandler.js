// Middleware to handle errors
function errorHandler(err, res, next) {
  // console.error(err.stack);

  res.status(err.status || 500).json({
    code: err.status || 500,
    message: err.message || 'Something went wrong'
  });
}

module.exports = errorHandler;

