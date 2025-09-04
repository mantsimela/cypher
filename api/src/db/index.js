const { drizzle } = require('drizzle-orm/postgres-js');
const postgres = require('postgres');
const config = require('../config');

// Create the connection string - Force use of AWS RDS from .env file
let connectionString = process.env.DATABASE_URL || config.DATABASE_URL;

// Override Replit's automatic database if AWS RDS URL is in .env
const fs = require('fs');
try {
  const envContent = fs.readFileSync('.env', 'utf8');
  const awsDbMatch = envContent.match(/DATABASE_URL=(.+rasdash-dev-public\.cexgrlslydeh\.us-east-1\.rds\.amazonaws\.com.+)/);
  if (awsDbMatch) {
    connectionString = awsDbMatch[1];
    console.log('🔧 Using AWS RDS database from .env file');
  }
} catch (e) {
  console.log('📝 Could not read .env file, using environment DATABASE_URL');
}

// If DATABASE_URL is not provided, build it from components
if (!connectionString) {
  const { DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD } = config;

  if (!DB_HOST || !DB_NAME || !DB_USER || !DB_PASSWORD) {
    throw new Error('Either DATABASE_URL or all DB component variables (DB_HOST, DB_NAME, DB_USER, DB_PASSWORD) are required');
  }

  connectionString = `postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}`;
  console.log(`📊 Built connection string from components: postgresql://${DB_USER}:***@${DB_HOST}:${DB_PORT}/${DB_NAME}`);
}

// Create postgres client using connection string approach
const client = postgres(connectionString, {
  max: 10, // Maximum number of connections
  idle_timeout: 20, // Close connections after 20 seconds of inactivity
  connect_timeout: 30, // Increased timeout for AWS RDS
  ssl: connectionString.includes('rasdash-dev-public') ? { rejectUnauthorized: false } : false, // Use SSL for AWS RDS
  transform: {
    undefined: null
  }
});

// Create drizzle instance
const db = drizzle(client);

// Test connection function
const testConnection = async () => {
  try {
    await client`SELECT 1`;
    console.log('✅ Database connection established successfully');
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    return false;
  }
};

// Graceful shutdown
const closeConnection = async () => {
  try {
    await client.end();
    console.log('Database connection closed');
  } catch (error) {
    console.error('Error closing database connection:', error.message);
  }
};

// Handle process termination
process.on('SIGINT', closeConnection);
process.on('SIGTERM', closeConnection);

module.exports = {
  db,
  client,
  testConnection,
  closeConnection,
};
