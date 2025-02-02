#!/usr/bin/python
# -*- coding:utf-8 -*-

import os
from dataclasses import dataclass
from multiprocessing import Process, Queue

import structlog
from PIL import Image
from PIL.ImageQt import ImageQt

# from lib.waveshare_epd import epd2in13b_V4
log = structlog.get_logger()

src_dir = os.path.dirname(os.path.realpath(__file__))
font_dir = os.path.join(src_dir, "fonts")
img_dir = os.path.join(src_dir, "img")


@dataclass
class Picture:
    image: Image.Image
    time: int


type PictureQueue = Queue[Picture]


def add_frame(queue: PictureQueue):
    while True:
        queue.put(Picture(Image.new("1", (250, 122), 255), 1))


if __name__ == "__main__":
    queue: PictureQueue = Queue()
    queue.put(Picture(Image.new("1", (250, 122), 255), 1))
    p = Process(target=add_frame, args=(queue,))
    p.start()

    while not queue.empty():
        print("getting")
        pic = queue.get()
        pic.image.show()

    p.join()

# try:
#     log.info("epd2in13b_V4 Demo")

#     # epd = epd2in13b_V4.EPD()
#     # log.info("init and Clear")
#     # epd.init()
#     # epd.Clear()
#     # time.sleep(1)

#     # Drawing on the image
#     log.info("Drawing")
#     font20 = ImageFont.truetype(os.path.join(font_dir, "Font.ttc"), 20)
#     font18 = ImageFont.truetype(os.path.join(font_dir, "Font.ttc"), 18)

#     # Drawing on the Horizontal image
#     log.info("1.Drawing on the Horizontal image...")
#     # HBlackimage = Image.new("1", (epd.height, epd.width), 255)  # 250*122
#     # HRYimage = Image.new("1", (epd.height, epd.width), 255)  # 250*122

#     HBlackimage = Image.new("1", (250, 122), 255)
#     HRYimage = Image.new("1", (250, 122), 255)

#     drawblack = ImageDraw.Draw(HBlackimage)
#     drawry = ImageDraw.Draw(HRYimage)
#     drawblack.text((10, 0), "hello world", font=font20, fill=0)
#     drawblack.text((10, 20), "2.13inch e-Paper b V4", font=font20, fill=0)
#     drawblack.text((120, 0), "微雪电子", font=font20, fill=0)
#     drawblack.line((20, 50, 70, 100), fill=0)
#     drawblack.line((70, 50, 20, 100), fill=0)
#     drawblack.rectangle((20, 50, 70, 100), outline=0)
#     drawry.line((165, 50, 165, 100), fill=0)
#     drawry.line((140, 75, 190, 75), fill=0)
#     drawry.arc((140, 50, 190, 100), 0, 360, fill=0)
#     drawry.rectangle((80, 50, 130, 100), fill=0)
#     drawry.chord((85, 55, 125, 95), 0, 360, fill=1)
#     # epd.display(epd.getbuffer(HBlackimage), epd.getbuffer(HRYimage))

#     HBlackimage.show()
#     HRYimage.show()

#     time.sleep(2)

#     # Drawing on the Vertical image
#     # log.info("2.Drawing on the Vertical image...")
#     # LBlackimage = Image.new("1", (epd.width, epd.height), 255)  # 122*250
#     # LRYimage = Image.new("1", (epd.width, epd.height), 255)  # 122*250
#     # drawblack = ImageDraw.Draw(LBlackimage)
#     # drawry = ImageDraw.Draw(LRYimage)
#     # drawblack.text((2, 0), "hello world", font=font18, fill=0)
#     # drawblack.text((2, 20), "2.13 epd b V4", font=font18, fill=0)
#     # drawblack.text((20, 50), "微雪电子", font=font18, fill=0)
#     # drawblack.line((10, 90, 60, 140), fill=0)
#     # drawblack.line((60, 90, 10, 140), fill=0)
#     # drawblack.rectangle((10, 90, 60, 140), outline=0)
#     # drawry.rectangle((10, 150, 60, 200), fill=0)
#     # drawry.arc((15, 95, 55, 135), 0, 360, fill=0)
#     # drawry.chord((15, 155, 55, 195), 0, 360, fill=1)
#     # epd.display(epd.getbuffer(LBlackimage), epd.getbuffer(LRYimage))
#     # time.sleep(2)

#     # log.info("3.read bmp file")
#     # Blackimage = Image.open(os.path.join(picdir, "2in13b_V4b.bmp"))
#     # RYimage = Image.open(os.path.join(picdir, "2in13b_V4b.bmp"))
#     # epd.display(epd.getbuffer(Blackimage), epd.getbuffer(RYimage))
#     # time.sleep(2)

#     # log.info("4.read bmp file on window")
#     # blackimage1 = Image.new("1", (epd.height, epd.width), 255)  # 250*122
#     # redimage1 = Image.new("1", (epd.height, epd.width), 255)  # 250*122
#     # newimage = Image.open(os.path.join(picdir, "100x100.bmp"))
#     # blackimage1.paste(newimage, (0, 0))
#     # epd.display(epd.getbuffer(blackimage1), epd.getbuffer(redimage1))

#     # log.info("Clear...")
#     # epd.init()
#     # epd.clear()

#     # log.info("Goto Sleep...")
#     # epd.sleep()

# except IOError as e:
#     log.info(e)

# except KeyboardInterrupt:
#     log.info("ctrl + c:")
#     # epd2in13b_V4.epdconfig.module_exit(cleanup=True)
#     exit()
