#!/usr/bin/env python3
"""
Generate app icon images for MedibankNews app
Uses blue and red as primary theme colors
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import os
except ImportError:
    print("Please install Pillow: pip install Pillow")
    exit(1)

# Color definitions
BLUE = (0, 122, 255)  # iOS Blue
RED = (255, 59, 48)   # iOS Red
WHITE = (255, 255, 255)
DARK_BLUE = (0, 100, 210)

def create_icon(size):
    """Create an app icon of the specified size"""
    # Create image with rounded corners
    img = Image.new('RGB', (size, size), color=WHITE)
    draw = ImageDraw.Draw(img)
    
    # Draw background gradient (blue to red diagonal)
    for i in range(size):
        # Create a diagonal gradient effect
        ratio = i / size
        r = int(BLUE[0] * (1 - ratio) + RED[0] * ratio)
        g = int(BLUE[1] * (1 - ratio) + RED[1] * ratio)
        b = int(BLUE[2] * (1 - ratio) + RED[2] * ratio)
        draw.line([(i, 0), (i, size)], fill=(r, g, b))
    
    # Draw a newspaper icon in the center
    center_x, center_y = size // 2, size // 2
    icon_size = int(size * 0.5)
    
    # Draw newspaper shape (rectangle with lines)
    margin = int(size * 0.15)
    paper_width = int(size * 0.7)
    paper_height = int(size * 0.6)
    paper_x = center_x - paper_width // 2
    paper_y = center_y - paper_height // 2
    
    # Draw paper background (white with slight transparency effect)
    paper_bg = (250, 250, 250)
    draw.rectangle(
        [paper_x, paper_y, paper_x + paper_width, paper_y + paper_height],
        fill=paper_bg,
        outline=WHITE,
        width=int(size * 0.02)
    )
    
    # Draw newspaper lines (text lines)
    line_spacing = paper_height // 8
    line_width = int(paper_width * 0.8)
    line_x = paper_x + int(paper_width * 0.1)
    
    for i in range(1, 7):
        y = paper_y + line_spacing * i
        # Alternate between full width and shorter lines
        if i % 2 == 0:
            draw.rectangle(
                [line_x, y, line_x + line_width, y + int(size * 0.015)],
                fill=DARK_BLUE
            )
        else:
            draw.rectangle(
                [line_x, y, line_x + int(line_width * 0.7), y + int(size * 0.015)],
                fill=DARK_BLUE
            )
    
    # Draw a small "M" letter in the top left corner (for Medibank)
    letter_size = int(size * 0.12)
    letter_x = paper_x + int(paper_width * 0.1)
    letter_y = paper_y + int(paper_height * 0.1)
    
    # Draw "M" shape
    m_width = letter_size
    m_height = letter_size
    m_thickness = int(size * 0.02)
    
    # Left vertical line
    draw.rectangle(
        [letter_x, letter_y, letter_x + m_thickness, letter_y + m_height],
        fill=RED
    )
    # Right vertical line
    draw.rectangle(
        [letter_x + m_width - m_thickness, letter_y, letter_x + m_width, letter_y + m_height],
        fill=RED
    )
    # Left diagonal
    draw.polygon(
        [(letter_x, letter_y), (letter_x + m_width // 2, letter_y + m_height // 2), 
         (letter_x + m_thickness, letter_y + m_height // 2), (letter_x + m_thickness, letter_y)],
        fill=RED
    )
    # Right diagonal
    draw.polygon(
        [(letter_x + m_width, letter_y), (letter_x + m_width // 2, letter_y + m_height // 2),
         (letter_x + m_width - m_thickness, letter_y + m_height // 2), (letter_x + m_width - m_thickness, letter_y)],
        fill=RED
    )
    
    return img

def generate_all_icons():
    """Generate all required icon sizes"""
    # Define all required sizes
    sizes = {
        # iPhone
        'iphone-20@2x': 40,
        'iphone-20@3x': 60,
        'iphone-29@2x': 58,
        'iphone-29@3x': 87,
        'iphone-40@2x': 80,
        'iphone-40@3x': 120,
        'iphone-60@2x': 120,
        'iphone-60@3x': 180,
        # iPad
        'ipad-20@2x': 40,
        'ipad-29@2x': 58,
        'ipad-40@2x': 80,
        'ipad-76@2x': 152,
        'ipad-83.5@2x': 167,
        # Marketing
        'ios-marketing-1024': 1024,
    }
    
    output_dir = 'Resources/Assets.xcassets/AppIcon.appiconset'
    os.makedirs(output_dir, exist_ok=True)
    
    print("Generating app icons...")
    for name, size in sizes.items():
        icon = create_icon(size)
        filename = f"{name}.png"
        filepath = os.path.join(output_dir, filename)
        icon.save(filepath, 'PNG')
        print(f"Created {filename} ({size}x{size})")
    
    print("\nAll icons generated successfully!")
    print(f"Icons saved to: {output_dir}")

if __name__ == '__main__':
    generate_all_icons()

