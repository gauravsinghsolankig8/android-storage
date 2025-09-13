#!/bin/bash

# Saranam App Development Startup Script
# This script starts all development servers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null ; then
        return 0
    else
        return 1
    fi
}

# Function to start backend
start_backend() {
    print_status "Starting backend server..."
    cd backend
    
    if [ ! -f ".env" ]; then
        print_error "Backend .env file not found! Please run setup first."
        exit 1
    fi
    
    if check_port 3000; then
        print_error "Port 3000 is already in use. Please stop the service using that port."
        exit 1
    fi
    
    print_success "Backend server starting on http://localhost:3000"
    npm run dev &
    BACKEND_PID=$!
    cd ..
}

# Function to start admin panel
start_admin() {
    print_status "Starting admin panel..."
    cd admin
    
    if check_port 3001; then
        print_error "Port 3001 is already in use. Please stop the service using that port."
        exit 1
    fi
    
    print_success "Admin panel starting on http://localhost:3001"
    npm start &
    ADMIN_PID=$!
    cd ..
}

# Function to start mobile app
start_mobile() {
    print_status "Starting mobile app..."
    cd frontend
    
    print_success "Mobile app starting with Expo..."
    print_status "Scan the QR code with Expo Go app on your phone"
    npx expo start &
    MOBILE_PID=$!
    cd ..
}

# Function to cleanup on exit
cleanup() {
    print_status "Stopping all services..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    if [ ! -z "$ADMIN_PID" ]; then
        kill $ADMIN_PID 2>/dev/null || true
    fi
    if [ ! -z "$MOBILE_PID" ]; then
        kill $MOBILE_PID 2>/dev/null || true
    fi
    print_success "All services stopped"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Main function
main() {
    echo "🚀 Starting Saranam Development Environment"
    echo "=========================================="
    
    # Check if setup has been run
    if [ ! -d "backend/node_modules" ] || [ ! -d "frontend/node_modules" ] || [ ! -d "admin/node_modules" ]; then
        print_error "Dependencies not installed. Please run setup first:"
        print_error "bash scripts/setup.sh"
        exit 1
    fi
    
    # Start services
    start_backend
    sleep 2
    start_admin
    sleep 2
    start_mobile
    
    echo ""
    echo "🎉 All services started successfully!"
    echo ""
    echo "Services running:"
    echo "• Backend API: http://localhost:3000"
    echo "• Admin Panel: http://localhost:3001"
    echo "• Mobile App: Expo development server"
    echo ""
    echo "Press Ctrl+C to stop all services"
    echo ""
    
    # Wait for user to stop
    wait
}

# Run main function
main