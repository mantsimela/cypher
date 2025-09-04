# RAS Dashboard Full Stack Application

## Overview

The RAS Dashboard is a comprehensive cybersecurity and risk management platform built with a modern full-stack architecture. It provides vulnerability management, asset tracking, compliance monitoring, and risk assessment capabilities for enterprise environments. The application includes an integrated scanning engine, AI-powered analytics, and Risk Management Framework (RMF) implementation for government and enterprise compliance.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Backend Architecture
- **Framework**: Node.js with Express.js REST API
- **Database**: PostgreSQL with Drizzle ORM for type-safe database operations
- **Authentication**: JWT-based authentication with role-based access control (RBAC)
- **API Design**: RESTful endpoints with comprehensive validation using Joi schemas
- **Performance**: Deferred service initialization and background processing to optimize startup times

### Frontend Architecture
- **Framework**: React 18 with Vite for fast development and building
- **State Management**: React hooks with custom lazy loading patterns for performance
- **UI Library**: Bootstrap 5 with custom dashboard components
- **Routing**: React Router for client-side navigation
- **Data Fetching**: Axios with React Query for efficient API communication and caching

### Database Design
- **ORM**: Drizzle ORM provides type-safe database interactions and automatic migration generation
- **Schema Management**: Modular schema files organized by domain (users, assets, vulnerabilities, etc.)
- **Performance**: Optimized indexes and foreign key relationships for complex queries
- **Audit Trails**: Comprehensive audit logging for all critical operations

### Security Architecture
- **Authentication**: JWT tokens with refresh token rotation
- **Authorization**: Role-based permissions system with granular access controls
- **Data Protection**: Input validation, SQL injection prevention, and secure headers
- **Audit Logging**: Complete audit trail for compliance and security monitoring

### Performance Optimization
- **Lazy Loading**: Component and data lazy loading to reduce initial bundle size
- **Caching**: Smart caching strategies with configurable cache times
- **Background Services**: Non-blocking initialization of heavy services during startup
- **Bundle Optimization**: Advanced code splitting and dependency optimization

### Scanning Engine
- **Network Scanning**: Port scanning, service detection, and vulnerability assessment
- **Security Assessment**: SSL/TLS analysis, web application scanning, and configuration auditing
- **Cloud Security**: AWS resource scanning and multi-cloud support
- **Compliance**: Government compliance frameworks and automated reporting

## External Dependencies

### Core Infrastructure
- **Database**: PostgreSQL for primary data storage
- **Node.js Runtime**: Version 16+ for backend execution
- **Authentication Service**: JWT implementation with bcrypt for password hashing

### AWS Cloud Services
- **Amazon SES**: Email delivery and notification system
- **AWS SDK**: Cloud resource management and scanning capabilities
- **S3 Storage**: File storage for reports and artifacts

### Development and Build Tools
- **Vite**: Frontend build tool and development server
- **Drizzle Kit**: Database migration and schema management
- **Concurrently**: Parallel execution of frontend and backend during development

### Third-Party Integrations
- **OpenAI API**: AI-powered analytics and natural language query processing
- **NIST CVE Database**: Vulnerability data feeds and security intelligence
- **Network Scanning Libraries**: Custom scanning engine with security assessment capabilities

### Security and Compliance
- **NIST RMF**: Risk Management Framework implementation
- **STIG Compliance**: Security Technical Implementation Guides
- **Vulnerability Databases**: CVE mapping and patch management data sources

### Monitoring and Analytics
- **Audit System**: Comprehensive logging and compliance tracking
- **Metrics Collection**: Performance monitoring and system health tracking
- **Notification System**: Multi-channel alerting and communication