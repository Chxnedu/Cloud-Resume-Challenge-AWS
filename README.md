# Cloud Resume Portfolio

A modern, minimal portfolio website built as an upgrade to the Cloud Resume Challenge.

## Features

- Semantic HTML5 structure
- Modern CSS with custom properties
- Vanilla JavaScript (no frameworks)
- Fully responsive design
- Visitor counter integration with AWS API Gateway
- Clean, professional aesthetic

## Structure

```
/
├── index.html          # Main HTML file
├── css/
│   └── style.css       # All styles
├── js/
│   └── main.js         # JavaScript functionality
├── assets/
│   └── images/         # Image assets
└── README.md           # This file
```

## Local Development

Simply open `index.html` in your browser. No build process required.

## Customization

1. Replace placeholder text in `index.html` with your actual information
2. Update the profile image in `assets/images/`
3. Add your actual resume PDF to `assets/`
4. Update social media links in the footer
5. Modify the color scheme in `css/style.css` CSS variables if desired

## Visitor Counter

The visitor counter integrates with the Cloud Resume Challenge API endpoint. It fetches the count from:
```
https://x2ufdd9eb5.execute-api.us-east-1.amazonaws.com/update_count
```

If you have a different API endpoint, update it in `js/main.js`.

## Technologies

- HTML5
- CSS3 (Flexbox, Grid, Custom Properties)
- Vanilla JavaScript
- Google Fonts (Inter)

## Design Principles

- Minimal and elegant
- Professional engineering aesthetic
- Fast load times
- Accessible and semantic markup
- Mobile-first responsive design
