import os
from PIL import Image, ImageDraw, ImageFont

ASSETS_DIR = r"c:\Users\User\Desktop\AiProjects\flutter_application_1\assets\emergency\illustrations"
os.makedirs(ASSETS_DIR, exist_ok=True)

def create_base_canvas(width=800, height=600):
    img = Image.new("RGBA", (width, height), (255, 255, 255, 255))
    draw = ImageDraw.Draw(img)
    # Background soft ground ellipse
    draw.ellipse([80, 490, 720, 550], fill=(236, 239, 241, 255))
    return img, draw

def save_image(img, filename):
    rgb_img = Image.new("RGB", img.size, (255, 255, 255))
    rgb_img.paste(img, mask=img.split()[3]) # paste using alpha mask
    target_path = os.path.join(ASSETS_DIR, filename)
    rgb_img.save(target_path, "PNG", quality=95)
    print(f"Saved: {target_path}")

def draw_badge(draw, text, fill_color, text_color):
    draw.rounded_rectangle([30, 30, 30 + len(text)*14 + 40, 75], radius=22, fill=fill_color)
    try:
        font = ImageFont.truetype("arial.ttf", 22)
    except Exception:
        font = ImageFont.load_default()
    draw.text((50, 42), text, fill=text_color, font=font)

# 1. Heat Stroke - Cooling Skin
def gen_heat_stroke():
    img, draw = create_base_canvas()
    # Bed base
    draw.rounded_rectangle([100, 380, 700, 480], radius=15, fill=(207, 216, 220, 255))
    # Pillow
    draw.rounded_rectangle([120, 310, 250, 400], radius=20, fill=(245, 245, 245, 255), outline=(176, 190, 197, 255), width=3)
    # Resting person body
    draw.polygon([(220, 370), (450, 360), (620, 410), (610, 450), (220, 450)], fill=(187, 222, 251, 255))
    # Head on pillow
    draw.ellipse([160, 250, 280, 370], fill=(255, 224, 178, 255))
    # Hair
    draw.chord([155, 240, 285, 340], start=160, end=360, fill=(69, 90, 100, 255))
    # Closed calm eye
    draw.arc([220, 300, 245, 315], start=0, end=180, fill=(120, 144, 156, 255), width=3)
    # Wet compress on forehead (blue)
    draw.rounded_rectangle([190, 260, 270, 290], radius=8, fill=(3, 169, 244, 255))
    draw.rounded_rectangle([195, 265, 265, 275], radius=4, fill=(179, 229, 252, 255))
    # Wet compress on neck
    draw.rounded_rectangle([250, 340, 310, 370], radius=8, fill=(3, 169, 244, 255))
    # Wet compress under armpit
    draw.rounded_rectangle([340, 360, 410, 395], radius=8, fill=(3, 169, 244, 255))
    # Water droplets
    for drop_pos in [(230, 210), (380, 320), (500, 300)]:
        draw.ellipse([drop_pos[0], drop_pos[1], drop_pos[0]+16, drop_pos[1]+22], fill=(2, 136, 209, 255))
    # Cooling breeze curves
    draw.arc([400, 140, 600, 220], start=200, end=340, fill=(41, 182, 246, 255), width=5)
    draw.arc([430, 180, 630, 260], start=200, end=340, fill=(79, 195, 247, 255), width=4)
    draw.arc([460, 220, 660, 300], start=200, end=340, fill=(129, 212, 250, 255), width=3)
    draw_badge(draw, "Cool Damp Cloths on Skin", (225, 245, 254, 255), (2, 136, 209, 255))
    save_image(img, "heat_stroke_cool_skin.png")

# 2. Chest Pain - Upright Sitting
def gen_chest_pain():
    img, draw = create_base_canvas()
    # Wall support on left
    draw.rectangle([120, 80, 180, 500], fill=(207, 216, 220, 255))
    # Pillow supporting back
    draw.rounded_rectangle([170, 280, 240, 460], radius=25, fill=(176, 190, 197, 255))
    # Head
    draw.ellipse([250, 140, 350, 240], fill=(255, 224, 178, 255))
    # Hair
    draw.chord([245, 130, 355, 210], start=160, end=360, fill=(69, 90, 100, 255))
    # Torso seated leaning back at comfortable angle
    draw.polygon([(260, 240), (220, 430), (370, 430), (340, 240)], fill=(66, 165, 245, 255))
    # Loosened open collar
    draw.line([(290, 240), (300, 280), (310, 240)], fill=(255, 255, 255, 255), width=5)
    # Arms resting supported
    draw.polygon([(260, 270), (330, 330), (360, 310), (290, 250)], fill=(144, 202, 249, 255))
    # Bent knees (W-sitting posture)
    draw.polygon([(360, 410), (480, 330), (520, 360), (430, 470), (360, 470)], fill=(84, 110, 122, 255))
    draw.polygon([(480, 330), (530, 480), (490, 480), (450, 360)], fill=(69, 90, 100, 255))
    draw.ellipse([480, 470, 545, 500], fill=(55, 71, 79, 255))
    # Back support indicator arrow
    draw.arc([130, 220, 210, 300], start=30, end=150, fill=(46, 125, 50, 255), width=6)
    draw_badge(draw, "Upright 'W' Sitting Posture", (232, 245, 233, 255), (46, 125, 50, 255))
    save_image(img, "chest_pain_sit_upright.png")

# 3. Poisoning - Wash Skin
def gen_poison_wash():
    img, draw = create_base_canvas()
    # Water tap / faucet
    draw.rounded_rectangle([200, 80, 370, 120], radius=8, fill=(120, 144, 156, 255))
    draw.rounded_rectangle([330, 110, 390, 180], radius=6, fill=(144, 164, 174, 255))
    draw.ellipse([345, 80, 375, 110], fill=(84, 110, 122, 255))
    # Water stream
    draw.polygon([(340, 180), (320, 500), (400, 500), (380, 180)], fill=(129, 212, 250, 220))
    draw.polygon([(350, 180), (340, 500), (380, 500), (370, 180)], fill=(225, 245, 254, 240))
    # Forearm under water
    draw.polygon([(100, 320), (340, 290), (450, 310), (440, 360), (320, 350), (100, 370)], fill=(255, 224, 178, 255))
    # Hand rubbing with soap
    draw.ellipse([330, 260, 420, 330], fill=(255, 204, 128, 255))
    # Soap bar
    draw.rounded_rectangle([310, 240, 380, 280], radius=14, fill=(128, 203, 196, 255), outline=(0, 137, 123, 255), width=3)
    # Lather / Bubbles
    for bub in [(290, 290, 20), (380, 270, 18), (350, 350, 24), (430, 320, 16), (310, 340, 18)]:
        draw.ellipse([bub[0], bub[1], bub[0]+bub[2], bub[1]+bub[2]], fill=(224, 247, 250, 240), outline=(77, 208, 225, 255), width=2)
    draw_badge(draw, "Wash Skin with Soap & Water", (224, 242, 241, 255), (0, 121, 107, 255))
    save_image(img, "poison_wash_skin.png")

# 4. High Fever - Sponging Forehead
def gen_fever_sponge():
    img, draw = create_base_canvas()
    # Pillow
    draw.rounded_rectangle([100, 300, 360, 440], radius=30, fill=(236, 239, 241, 255), outline=(207, 216, 220, 255), width=4)
    # Head
    draw.ellipse([180, 240, 340, 390], fill=(255, 224, 178, 255))
    # Hair
    draw.chord([170, 225, 345, 330], start=160, end=360, fill=(69, 90, 100, 255))
    # Soft fever blush
    draw.ellipse([270, 325, 310, 350], fill=(255, 138, 128, 140))
    # Blanket
    draw.rounded_rectangle([270, 350, 680, 480], radius=20, fill=(144, 202, 249, 255))
    # Water Bowl on side
    draw.rounded_rectangle([480, 240, 620, 350], radius=25, fill=(207, 216, 220, 255), outline=(176, 190, 197, 255), width=3)
    draw.ellipse([490, 245, 610, 280], fill=(79, 195, 247, 255))
    # Rescuer hand holding cloth
    draw.rounded_rectangle([250, 160, 330, 250], radius=20, fill=(255, 204, 128, 255))
    # Damp folded sponge cloth
    draw.rounded_rectangle([200, 235, 330, 285], radius=14, fill=(225, 245, 254, 255), outline=(2, 136, 209, 255), width=4)
    draw.line([(215, 260), (315, 260)], fill=(129, 212, 250, 255), width=3)
    # Water drops
    draw.ellipse([240, 290, 254, 310], fill=(2, 136, 209, 255))
    draw_badge(draw, "Tepid Water Sponging", (225, 245, 254, 255), (2, 136, 209, 255))
    save_image(img, "fever_sponge_forehead.png")

# 5. Pregnancy - Left Side L-Position
def gen_pregnancy_left_side():
    img, draw = create_base_canvas()
    # Bed / Mattress
    draw.rounded_rectangle([80, 420, 720, 490], radius=15, fill=(207, 216, 220, 255))
    # Pillow under head
    draw.rounded_rectangle([110, 310, 230, 400], radius=20, fill=(236, 239, 241, 255), outline=(176, 190, 197, 255), width=3)
    # Head & hair
    draw.ellipse([140, 260, 240, 360], fill=(255, 224, 178, 255))
    draw.chord([130, 250, 245, 335], start=160, end=360, fill=(78, 52, 46, 255))
    # Upper body in pink maternity top
    draw.polygon([(200, 320), (370, 310), (370, 420), (200, 420)], fill=(244, 143, 177, 255))
    # Pregnant belly contour (supported)
    draw.ellipse([280, 300, 400, 420], fill=(240, 98, 146, 255))
    # Legs resting on left side with knee bent
    draw.polygon([(360, 380), (580, 360), (600, 440), (360, 440)], fill=(206, 147, 216, 255))
    # Pillow between knees
    draw.ellipse([460, 360, 540, 430], fill=(225, 190, 231, 255), outline=(171, 71, 188, 255), width=3)
    # Placental blood flow arrow
    draw.arc([300, 210, 420, 300], start=30, end=170, fill=(233, 30, 99, 255), width=5)
    draw_badge(draw, "Rest on Left Side (L-Position)", (252, 228, 236, 255), (194, 24, 91, 255))
    save_image(img, "pregnancy_left_side.png")

# 6. Immediate Childbirth - Wash Hands
def gen_wash_hands():
    img, draw = create_base_canvas()
    # Water tap / faucet
    draw.rounded_rectangle([200, 80, 370, 120], radius=8, fill=(120, 144, 156, 255))
    draw.rounded_rectangle([330, 110, 390, 180], radius=6, fill=(144, 164, 174, 255))
    draw.ellipse([345, 80, 375, 110], fill=(84, 110, 122, 255))
    # Clean running water
    draw.polygon([(340, 180), (320, 500), (400, 500), (380, 180)], fill=(129, 212, 250, 220))
    draw.polygon([(350, 180), (340, 500), (380, 500), (370, 180)], fill=(225, 245, 254, 240))
    # Two Hands Interlocking & scrubbing with soap lather
    draw.ellipse([240, 290, 380, 390], fill=(255, 224, 178, 255))
    draw.ellipse([320, 270, 460, 380], fill=(255, 204, 128, 255))
    # Fingers scrub pattern
    for i in range(4):
        draw.rounded_rectangle([370 + i*15, 280 + i*10, 420 + i*15, 310 + i*10], radius=8, fill=(255, 204, 128, 255))
    # Abundant clean soap lather foam
    for bub in [(270, 310, 35), (340, 290, 40), (310, 360, 38), (390, 330, 30), (250, 345, 28), (420, 350, 25)]:
        draw.ellipse([bub[0], bub[1], bub[0]+bub[2], bub[1]+bub[2]], fill=(255, 255, 255, 250), outline=(178, 235, 242, 255), width=3)
    draw_badge(draw, "Surgical Clean Hand Washing", (232, 245, 233, 255), (46, 125, 50, 255))
    save_image(img, "wash_hands_clean.png")

# 7. Electric Shock - Wooden Stick
def gen_electric_stick():
    img, draw = create_base_canvas()
    # Victim on right
    draw.ellipse([540, 380, 620, 460], fill=(255, 224, 178, 255))
    draw.polygon([(400, 410), (560, 390), (560, 470), (400, 470)], fill=(144, 202, 249, 255))
    # Live electric wire on ground
    draw.arc([350, 370, 520, 470], start=30, end=190, fill=(211, 47, 47, 255), width=7)
    # Spark warning
    draw.polygon([(440, 350), (460, 380), (445, 385), (465, 415), (435, 390), (445, 370)], fill=(251, 192, 45, 255), outline=(245, 127, 23, 255))
    # Rescuer standing at safe distance on left
    draw.ellipse([140, 150, 200, 220], fill=(255, 224, 178, 255))
    draw.chord([135, 140, 205, 195], start=160, end=360, fill=(55, 71, 79, 255))
    draw.polygon([(140, 220), (120, 370), (210, 370), (200, 220)], fill=(66, 165, 245, 255))
    draw.rectangle([130, 370, 160, 490], fill=(69, 90, 100, 255))
    draw.rectangle([170, 370, 200, 490], fill=(69, 90, 100, 255))
    # Rescuer arms holding long dry wooden stick
    draw.line([(170, 260), (240, 290)], fill=(255, 224, 178, 255), width=16)
    # Long dry wooden pole pushing wire away
    draw.line([(220, 280), (460, 400)], fill=(141, 110, 99, 255), width=14)
    draw.line([(220, 280), (460, 400)], fill=(161, 136, 127, 255), width=6)
    draw_badge(draw, "Push Wire with Dry Wooden Stick", (255, 243, 224, 255), (230, 81, 0, 255))
    save_image(img, "electric_wooden_stick.png")

# 8. Fracture - Ice Pack
def gen_fracture_ice():
    img, draw = create_base_canvas()
    # Pillow supporting injured leg
    draw.rounded_rectangle([150, 330, 620, 440], radius=30, fill=(236, 239, 241, 255), outline=(207, 216, 220, 255), width=4)
    # Injured limb / ankle
    draw.polygon([(100, 290), (440, 290), (550, 320), (570, 370), (440, 360), (100, 360)], fill=(255, 224, 178, 255))
    # Swelling indicator
    draw.ellipse([420, 300, 490, 350], fill=(255, 205, 210, 180))
    # Towel wrapped around ice pack
    draw.rounded_rectangle([370, 220, 520, 330], radius=22, fill=(225, 245, 254, 255), outline=(2, 136, 209, 255), width=4)
    # Ice pack cap
    draw.rounded_rectangle([425, 185, 465, 220], radius=8, fill=(2, 136, 209, 255))
    # Cold rays
    draw.line([(350, 200), (330, 180)], fill=(41, 182, 246, 255), width=4)
    draw.line([(540, 200), (560, 180)], fill=(41, 182, 246, 255), width=4)
    draw.line([(445, 160), (445, 140)], fill=(41, 182, 246, 255), width=4)
    draw_badge(draw, "Ice Pack Wrapped in Cloth", (225, 245, 254, 255), (2, 136, 209, 255))
    save_image(img, "fracture_ice_pack.png")

if __name__ == "__main__":
    gen_heat_stroke()
    gen_chest_pain()
    gen_poison_wash()
    gen_fever_sponge()
    gen_pregnancy_left_side()
    gen_wash_hands()
    gen_electric_stick()
    gen_fracture_ice()
    print("All 8 PNG medical illustrations generated successfully!")
