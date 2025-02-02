from PIL import Image, ImageDraw



class FrameDrawer:
    def __init__(self):
        self.frame = Image.new("1", (250, 122), 255)
        self.draw = ImageDraw.Draw(self.frame)

    def draw_text(self, text: str, position: tuple[int, int]):
        self.draw.text(position, text, fill=0)

    def get_frame(self) -> Image.Image:
        return self.frame
    
    




def get_next_frame() -> Image.Image:
    
    
    
    
    image = Image.new("1", (250, 122), 255)
    draw = ImageDraw.Draw(image)
    draw.text((10, 0), "hello world", fill=0)

    return image
