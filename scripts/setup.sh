#!/bin/bash

# Saranam App Setup Script
# This script automates the initial setup of the Saranam application

set -e

echo "🚀 Starting Saranam App Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Node.js is installed
check_nodejs() {
    print_status "Checking Node.js installation..."
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js is installed: $NODE_VERSION"
    else
        print_error "Node.js is not installed. Please install Node.js v16 or higher."
        exit 1
    fi
}

# Check if MySQL is installed
check_mysql() {
    print_status "Checking MySQL installation..."
    if command -v mysql &> /dev/null; then
        print_success "MySQL is installed"
    else
        print_warning "MySQL is not installed. Please install MySQL v8.0 or higher."
        print_warning "You can continue with the setup and install MySQL later."
    fi
}

# Check if Git is installed
check_git() {
    print_status "Checking Git installation..."
    if command -v git &> /dev/null; then
        print_success "Git is installed"
    else
        print_error "Git is not installed. Please install Git."
        exit 1
    fi
}

# Install backend dependencies
setup_backend() {
    print_status "Setting up backend..."
    cd backend
    
    if [ ! -f "package.json" ]; then
        print_error "Backend package.json not found!"
        exit 1
    fi
    
    print_status "Installing backend dependencies..."
    npm install
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        print_status "Creating .env file..."
        cp .env.example .env
        print_warning "Please edit backend/.env file with your configuration"
    fi
    
    # Create uploads directory
    mkdir -p uploads
    
    print_success "Backend setup completed"
    cd ..
}

# Install frontend dependencies
setup_frontend() {
    print_status "Setting up mobile app frontend..."
    cd frontend
    
    if [ ! -f "package.json" ]; then
        print_error "Frontend package.json not found!"
        exit 1
    fi
    
    print_status "Installing frontend dependencies..."
    npm install
    
    # Create assets directories
    mkdir -p assets/fonts
    mkdir -p assets/images
    
    print_success "Frontend setup completed"
    cd ..
}

# Install admin panel dependencies
setup_admin() {
    print_status "Setting up admin panel..."
    cd admin
    
    if [ ! -f "package.json" ]; then
        print_error "Admin package.json not found!"
        exit 1
    fi
    
    print_status "Installing admin panel dependencies..."
    npm install
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        print_status "Creating .env file..."
        echo "REACT_APP_API_URL=http://localhost:3000/api" > .env
    fi
    
    print_success "Admin panel setup completed"
    cd ..
}

# Setup database
setup_database() {
    print_status "Setting up database..."
    
    if ! command -v mysql &> /dev/null; then
        print_warning "MySQL not found. Skipping database setup."
        print_warning "Please install MySQL and run the database setup manually."
        return
    fi
    
    print_status "Please enter your MySQL root password:"
    read -s MYSQL_PASSWORD
    
    # Create database
    print_status "Creating database..."
    mysql -u root -p$MYSQL_PASSWORD -e "CREATE DATABASE IF NOT EXISTS saranam_db;" 2>/dev/null || {
        print_error "Failed to create database. Please check your MySQL credentials."
        return
    }
    
    # Import schema
    print_status "Importing database schema..."
    mysql -u root -p$MYSQL_PASSWORD saranam_db < db/schema.sql 2>/dev/null || {
        print_error "Failed to import schema. Please check the schema file."
        return
    }
    
    print_success "Database setup completed"
}

# Install Expo CLI
install_expo_cli() {
    print_status "Installing Expo CLI..."
    if command -v expo &> /dev/null; then
        print_success "Expo CLI is already installed"
    else
        npm install -g @expo/cli
        print_success "Expo CLI installed"
    fi
}

# Main setup function
main() {
    echo "🎯 Saranam - Vrindavan Spiritual Guide App Setup"
    echo "================================================"
    
    # Check prerequisites
    check_nodejs
    check_mysql
    check_git
    
    # Setup components
    setup_backend
    setup_frontend
    setup_admin
    install_expo_cli
    
    # Setup database (optional)
    echo ""
    read -p "Do you want to setup the database now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_database
    fi
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Edit backend/.env with your configuration"
    echo "2. Start the backend: cd backend && npm run dev"
    echo "3. Start the mobile app: cd frontend && npx expo start"
    echo "4. Start the admin panel: cd admin && npm start"
    echo ""
    echo "For detailed setup instructions, see SETUP.md"
}

# Run main function
main