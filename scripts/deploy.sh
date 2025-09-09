#!/bin/bash

# Saranam App Deployment Script
# This script helps deploy the application to production

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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to build backend
build_backend() {
    print_status "Building backend for production..."
    cd backend
    
    # Install production dependencies
    npm ci --only=production
    
    # Create production build directory
    mkdir -p dist
    
    # Copy necessary files
    cp -r routes dist/
    cp -r config dist/
    cp -r middleware dist/
    cp -r services dist/
    cp server.js dist/
    cp package.json dist/
    
    print_success "Backend build completed"
    cd ..
}

# Function to build admin panel
build_admin() {
    print_status "Building admin panel for production..."
    cd admin
    
    # Install dependencies
    npm ci
    
    # Build for production
    npm run build
    
    print_success "Admin panel build completed"
    cd ..
}

# Function to build mobile app
build_mobile() {
    print_status "Building mobile app for production..."
    cd frontend
    
    # Check if EAS CLI is installed
    if ! command -v eas &> /dev/null; then
        print_status "Installing EAS CLI..."
        npm install -g @expo/eas-cli
    fi
    
    # Login to Expo (if not already logged in)
    print_status "Checking Expo authentication..."
    if ! eas whoami &> /dev/null; then
        print_warning "Please login to Expo:"
        eas login
    fi
    
    # Configure EAS (if not already configured)
    if [ ! -f "eas.json" ]; then
        print_status "Configuring EAS..."
        eas build:configure
    fi
    
    print_success "Mobile app ready for build"
    print_warning "Run 'eas build --platform ios' or 'eas build --platform android' to build"
    cd ..
}

# Function to deploy to Heroku
deploy_heroku() {
    print_status "Deploying to Heroku..."
    
    if ! command -v heroku &> /dev/null; then
        print_error "Heroku CLI not found. Please install it first."
        return 1
    fi
    
    # Check if logged in to Heroku
    if ! heroku auth:whoami &> /dev/null; then
        print_warning "Please login to Heroku:"
        heroku login
    fi
    
    # Create Heroku app (if it doesn't exist)
    if ! heroku apps:info saranam-backend &> /dev/null; then
        print_status "Creating Heroku app..."
        heroku create saranam-backend
    fi
    
    # Add MySQL addon
    print_status "Adding MySQL addon..."
    heroku addons:create jawsdb:kitefin || print_warning "MySQL addon might already exist"
    
    # Set environment variables
    print_status "Setting environment variables..."
    print_warning "Please set the following environment variables in Heroku:"
    echo "heroku config:set JWT_SECRET=your_jwt_secret"
    echo "heroku config:set DB_HOST=your_db_host"
    echo "heroku config:set DB_USER=your_db_user"
    echo "heroku config:set DB_PASSWORD=your_db_password"
    echo "heroku config:set DB_NAME=your_db_name"
    echo "heroku config:set NODE_ENV=production"
    
    # Deploy
    print_status "Deploying to Heroku..."
    git push heroku main
    
    print_success "Backend deployed to Heroku"
}

# Function to deploy to Vercel
deploy_vercel() {
    print_status "Deploying to Vercel..."
    
    if ! command -v vercel &> /dev/null; then
        print_error "Vercel CLI not found. Please install it first."
        return 1
    fi
    
    # Deploy backend
    cd backend
    vercel --prod
    cd ..
    
    # Deploy admin panel
    cd admin
    vercel --prod
    cd ..
    
    print_success "Deployed to Vercel"
}

# Function to deploy to Render
deploy_render() {
    print_status "Deploying to Render..."
    print_warning "Please deploy manually to Render:"
    echo "1. Connect your GitHub repository to Render"
    echo "2. Create a new Web Service for the backend"
    echo "3. Set build command: npm install"
    echo "4. Set start command: npm start"
    echo "5. Add environment variables"
    echo "6. Deploy"
}

# Main deployment function
main() {
    echo "🚀 Saranam App Deployment"
    echo "========================"
    
    # Check if we're in the right directory
    if [ ! -f "package.json" ] && [ ! -d "backend" ]; then
        print_error "Please run this script from the project root directory"
        exit 1
    fi
    
    # Build all components
    build_backend
    build_admin
    build_mobile
    
    echo ""
    echo "Choose deployment option:"
    echo "1) Heroku"
    echo "2) Vercel"
    echo "3) Render (Manual)"
    echo "4) Custom deployment"
    echo "5) Exit"
    
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1)
            deploy_heroku
            ;;
        2)
            deploy_vercel
            ;;
        3)
            deploy_render
            ;;
        4)
            print_status "Custom deployment selected"
            print_warning "Please follow your custom deployment process"
            ;;
        5)
            print_status "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
    
    echo ""
    echo "🎉 Deployment completed!"
    echo ""
    echo "Next steps:"
    echo "1. Update mobile app API URL to production endpoint"
    echo "2. Build and submit mobile app to app stores"
    echo "3. Configure domain and SSL certificates"
    echo "4. Set up monitoring and logging"
}

# Run main function
main