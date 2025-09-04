module.exports = {
  apps: [
    {
      name: 'ras-dashboard-api',
      script: './api/server.js',
      cwd: 'C:/inetpub/wwwroot/ras-dashboard',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 8080
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 8080
      },
      error_file: 'C:/logs/pm2/ras-dashboard-api-error.log',
      out_file: 'C:/logs/pm2/ras-dashboard-api-out.log',
      log_file: 'C:/logs/pm2/ras-dashboard-api.log',
      time: true,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      min_uptime: '10s',
      max_restarts: 10
    }
  ]
};