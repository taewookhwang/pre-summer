const winston = require('winston');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../Infrastructure/.env') });

// \� �� $
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

// \� � $
const logLevel = process.env.LOG_LEVEL || 'info';

// \� 	�� �1
const fs = require('fs');
const logDir = path.join(__dirname, '../../logs');
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir);
}

// \p �1
const logger = winston.createLogger({
  level: logLevel,
  format: logFormat,
  defaultMeta: { service: 'home-cleaning-service' },
  transports: [
    // X� �%
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.printf(
          info => `${info.timestamp} ${info.level}: ${info.message}`
        )
      )
    }),
    // |  � - �� \�
    new winston.transports.File({
      filename: path.join(logDir, 'combined.log')
    }),
    // |  � - �� \��
    new winston.transports.File({
      filename: path.join(logDir, 'error.log'),
      level: 'error'
    })
  ]
});

//  X��� X�� �8\ \� �%
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }));
}

module.exports = logger;