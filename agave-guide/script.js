// Mobile Navigation Toggle
document.addEventListener('DOMContentLoaded', function() {
    const hamburger = document.querySelector('.hamburger');
    const navMenu = document.querySelector('.nav-menu');
    const navLinks = document.querySelectorAll('.nav-link');

    // Toggle mobile menu
    if (hamburger) {
        hamburger.addEventListener('click', function() {
            hamburger.classList.toggle('active');
            navMenu.classList.toggle('active');
        });
    }

    // Close mobile menu when clicking on a link
    navLinks.forEach(link => {
        link.addEventListener('click', function() {
            if (hamburger) {
                hamburger.classList.remove('active');
                navMenu.classList.remove('active');
            }
        });
    });

    // Smooth scrolling for navigation links
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            const targetSection = document.querySelector(targetId);
            
            if (targetSection) {
                targetSection.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Tab functionality
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(button => {
        button.addEventListener('click', function() {
            const targetTab = this.getAttribute('data-tab');
            
            // Remove active class from all buttons and contents
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabContents.forEach(content => content.classList.remove('active'));
            
            // Add active class to clicked button and corresponding content
            this.classList.add('active');
            const targetContent = document.getElementById(targetTab);
            if (targetContent) {
                targetContent.classList.add('active');
            }
        });
    });

    // Command copy functionality
    const commandItems = document.querySelectorAll('.command-item');
    commandItems.forEach(item => {
        item.addEventListener('click', function() {
            const codeElement = this.querySelector('code');
            if (codeElement) {
                const textToCopy = codeElement.textContent;
                
                // Modern clipboard API
                if (navigator.clipboard && window.isSecureContext) {
                    navigator.clipboard.writeText(textToCopy).then(() => {
                        showCopyFeedback(this);
                    }).catch(() => {
                        fallbackCopyTextToClipboard(textToCopy);
                        showCopyFeedback(this);
                    });
                } else {
                    // Fallback for older browsers
                    fallbackCopyTextToClipboard(textToCopy);
                    showCopyFeedback(this);
                }
            }
        });
    });

    // Fallback copy function for older browsers
    function fallbackCopyTextToClipboard(text) {
        const textArea = document.createElement("textarea");
        textArea.value = text;
        
        // Avoid scrolling to bottom
        textArea.style.top = "0";
        textArea.style.left = "0";
        textArea.style.position = "fixed";
        
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        
        try {
            document.execCommand('copy');
        } catch (err) {
            console.error('Fallback: Oops, unable to copy', err);
        }
        
        document.body.removeChild(textArea);
    }

    // Show copy feedback
    function showCopyFeedback(element) {
        const originalText = element.querySelector('span').textContent;
        const spanElement = element.querySelector('span');
        
        spanElement.textContent = '✓ Copied to clipboard!';
        element.classList.add('success');
        
        setTimeout(() => {
            spanElement.textContent = originalText;
            element.classList.remove('success');
        }, 2000);
    }

    // Add copy buttons to code blocks
    const codeBlocks = document.querySelectorAll('pre');
    codeBlocks.forEach(block => {
        const copyButton = document.createElement('button');
        copyButton.textContent = 'Copy';
        copyButton.className = 'copy-button';
        copyButton.style.position = 'absolute';
        copyButton.style.top = '10px';
        copyButton.style.right = '10px';
        copyButton.style.opacity = '0';
        copyButton.style.transition = 'opacity 0.3s ease';
        copyButton.style.background = '#14F195';
        copyButton.style.color = 'white';
        copyButton.style.border = 'none';
        copyButton.style.padding = '5px 10px';
        copyButton.style.borderRadius = '4px';
        copyButton.style.cursor = 'pointer';
        copyButton.style.fontSize = '12px';
        copyButton.style.zIndex = '10';
        
        block.style.position = 'relative';
        block.appendChild(copyButton);
        
        // Show/hide copy button on hover
        block.addEventListener('mouseenter', () => {
            copyButton.style.opacity = '1';
        });
        
        block.addEventListener('mouseleave', () => {
            copyButton.style.opacity = '0';
        });
        
        // Copy functionality
        copyButton.addEventListener('click', () => {
            const codeText = block.querySelector('code').textContent;
            
            if (navigator.clipboard && window.isSecureContext) {
                navigator.clipboard.writeText(codeText).then(() => {
                    copyButton.textContent = '✓ Copied!';
                    setTimeout(() => {
                        copyButton.textContent = 'Copy';
                    }, 2000);
                });
            } else {
                fallbackCopyTextToClipboard(codeText);
                copyButton.textContent = '✓ Copied!';
                setTimeout(() => {
                    copyButton.textContent = 'Copy';
                }, 2000);
            }
        });
    });

    // Scroll spy for navigation
    const sections = document.querySelectorAll('.section');
    const navItems = document.querySelectorAll('.nav-link');

    function updateActiveNavItem() {
        let current = '';
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.clientHeight;
            if (pageYOffset >= sectionTop - 100) {
                current = section.getAttribute('id');
            }
        });

        navItems.forEach(item => {
            item.classList.remove('active');
            if (item.getAttribute('href') === '#' + current) {
                item.classList.add('active');
            }
        });
    }

    window.addEventListener('scroll', updateActiveNavItem);

    // Initialize scroll spy
    updateActiveNavItem();

    // Animate elements on scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe elements for animation
    const animateElements = document.querySelectorAll('.overview-card, .command-category, .component');
    animateElements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });

    // Search functionality (basic)
    const searchInput = document.createElement('input');
    searchInput.type = 'text';
    searchInput.placeholder = 'Search commands...';
    searchInput.style.cssText = `
        position: fixed;
        top: 80px;
        right: 20px;
        padding: 0.5rem;
        border: 1px solid #E0E0E0;
        border-radius: 4px;
        z-index: 999;
        display: none;
    `;
    document.body.appendChild(searchInput);

    // Toggle search with Ctrl+K or Cmd+K
    document.addEventListener('keydown', (e) => {
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
            e.preventDefault();
            searchInput.style.display = searchInput.style.display === 'none' ? 'block' : 'none';
            if (searchInput.style.display === 'block') {
                searchInput.focus();
            }
        }
        
        if (e.key === 'Escape') {
            searchInput.style.display = 'none';
            searchInput.value = '';
            clearSearchHighlight();
        }
    });

    // Simple search functionality
    searchInput.addEventListener('input', (e) => {
        const searchTerm = e.target.value.toLowerCase();
        clearSearchHighlight();
        
        if (searchTerm.length > 2) {
            highlightSearchResults(searchTerm);
        }
    });

    function highlightSearchResults(term) {
        const commandItems = document.querySelectorAll('.command-item code');
        commandItems.forEach(item => {
            if (item.textContent.toLowerCase().includes(term)) {
                item.parentElement.style.background = '#fff3cd';
                item.parentElement.style.border = '2px solid #ffc107';
            }
        });
    }

    function clearSearchHighlight() {
        const commandItems = document.querySelectorAll('.command-item');
        commandItems.forEach(item => {
            item.style.background = '';
            item.style.border = '';
        });
    }

    // Print functionality
    const printButton = document.createElement('button');
    printButton.textContent = '🖨️ Print Guide';
    printButton.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: #14F195;
        color: white;
        border: none;
        padding: 12px 20px;
        border-radius: 50px;
        cursor: pointer;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
        z-index: 999;
        font-weight: 600;
        transition: all 0.3s ease;
    `;
    
    printButton.addEventListener('click', () => {
        window.print();
    });
    
    printButton.addEventListener('mouseover', () => {
        printButton.style.transform = 'scale(1.05)';
        printButton.style.boxShadow = '0 6px 25px rgba(0, 0, 0, 0.2)';
    });
    
    printButton.addEventListener('mouseout', () => {
        printButton.style.transform = 'scale(1)';
        printButton.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.15)';
    });
    
    document.body.appendChild(printButton);

    console.log('🌱 Agave Developer Guide loaded successfully!');
}); 