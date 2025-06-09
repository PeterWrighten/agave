#!/bin/bash

# Agave Validator Documentation Opener
# Based on Bitcoin Core documentation pattern

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Documentation directory
DOCS_DIR="agave-guide"

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to open URL in browser
open_browser() {
    local file=$1
    local full_path="$PWD/$DOCS_DIR/$file"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open "file://$full_path"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v xdg-open > /dev/null; then
            xdg-open "file://$full_path"
        elif command -v firefox > /dev/null; then
            firefox "file://$full_path"
        elif command -v google-chrome > /dev/null; then
            google-chrome "file://$full_path"
        else
            print_color $RED "Error: No suitable browser found. Please open file://$full_path manually"
            return 1
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        # Windows
        start "file://$full_path"
    else
        print_color $RED "Error: Unsupported operating system. Please open file://$full_path manually"
        return 1
    fi
}

# Function to check if documentation exists
check_docs() {
    if [ ! -d "$DOCS_DIR" ]; then
        print_color $RED "Error: Documentation directory '$DOCS_DIR' not found!"
        print_color $YELLOW "Please ensure you're running this script from the correct directory."
        exit 1
    fi
}

# Function to display menu
show_menu() {
    print_color $PURPLE "🌪️ Agave Validator Documentation"
    print_color $CYAN "======================================"
    echo
    print_color $GREEN "Available documentation pages:"
    echo
    print_color $BLUE "  index        🏠 Main documentation hub"
    print_color $BLUE "  setup        ⚡ Environment setup guide"  
    print_color $BLUE "  architecture 🏗️ Technical architecture deep dive"
    print_color $BLUE "  commands     🔧 CLI commands reference"
    print_color $BLUE "  consensus    🔗 Consensus mechanisms (PoH, Tower BFT)"
    print_color $BLUE "  performance  ⚙️ Performance optimization guide"
    print_color $BLUE "  development  💻 Development and contribution guide"
    print_color $BLUE "  all          📚 Open all documentation pages"
    echo
    print_color $YELLOW "Usage: $0 [page_name]"
    print_color $YELLOW "Example: $0 setup"
    echo
}

# Function to open specific documentation page
open_page() {
    local page=$1
    
    case $page in
        "index"|"main"|"home"|"")
            print_color $GREEN "Opening main documentation hub..."
            open_browser "index.html"
            ;;
        "setup"|"install"|"environment")
            print_color $GREEN "Opening environment setup guide..."
            open_browser "setup.html"
            ;;
        "architecture"|"arch"|"technical")
            print_color $GREEN "Opening architecture deep dive..."
            open_browser "architecture.html"
            ;;
        "commands"|"cmd"|"cli"|"reference")
            print_color $GREEN "Opening commands reference..."
            open_browser "commands.html"
            ;;
        "consensus"|"poh"|"tower"|"bft")
            print_color $GREEN "Opening consensus mechanisms..."
            open_browser "consensus.html"
            ;;
        "performance"|"perf"|"optimization"|"tuning")
            print_color $GREEN "Opening performance optimization guide..."
            open_browser "performance.html"
            ;;
        "development"|"dev"|"contributing"|"contrib")
            print_color $GREEN "Opening development guide..."
            open_browser "development.html"
            ;;
        "all"|"everything")
            print_color $GREEN "Opening all documentation pages..."
            open_browser "index.html"
            sleep 1
            open_browser "setup.html"
            sleep 1
            open_browser "architecture.html"
            sleep 1
            open_browser "commands.html"
            sleep 1
            open_browser "consensus.html"
            sleep 1
            open_browser "performance.html"
            sleep 1
            open_browser "development.html"
            print_color $CYAN "All documentation pages opened!"
            ;;
        "help"|"-h"|"--help")
            show_menu
            ;;
        *)
            print_color $RED "Error: Unknown page '$page'"
            echo
            show_menu
            exit 1
            ;;
    esac
}

# Main script logic
main() {
    check_docs
    
    if [ $# -eq 0 ]; then
        # No arguments provided, show menu and open main page
        show_menu
        echo
        print_color $GREEN "Opening main documentation hub..."
        open_page "index"
    elif [ $# -eq 1 ]; then
        # One argument provided
        local page=$(echo "$1" | tr '[:upper:]' '[:lower:]')
        open_page "$page"
    else
        # Too many arguments
        print_color $RED "Error: Too many arguments provided"
        echo
        show_menu
        exit 1
    fi
}

# Trap to handle script interruption
trap 'print_color $YELLOW "\nScript interrupted by user"; exit 1' INT

# Run main function with all arguments
main "$@"

print_color $CYAN "Documentation access complete!"
print_color $YELLOW "Tip: Use '$0 help' to see all available options" 