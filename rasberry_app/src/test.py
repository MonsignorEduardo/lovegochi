import os
import sys
from multiprocessing import Process, Queue
from time import sleep

import structlog
from PIL import Image, ImageDraw
from PIL.ImageQt import ImageQt
from PyQt6.QtCore import QTimer
from PyQt6.QtGui import QPixmap
from PyQt6.QtWidgets import (
    QApplication,
    QLabel,
    QMainWindow,
    QPushButton,
    QVBoxLayout,
    QWidget,
)

from src.gui import get_next_frame

log = structlog.stdlib.get_logger()

type ImageQueue = Queue[Image.Image]


class ImageViewer(QMainWindow):
    def __init__(self, images: ImageQueue):
        super().__init__()
        self.images = images
        self.label = QLabel()

        self.label.setScaledContents(True)
        btn_next = QPushButton("Siguiente")
        btn_next.clicked.connect(self.next_image)

        layout = QVBoxLayout()
        layout.addWidget(self.label)
        layout.addWidget(btn_next)
        container = QWidget()
        container.setLayout(layout)
        self.setCentralWidget(container)

        self.timer = QTimer(self)
        self.timer.timeout.connect(self.next_image)
        self.timer.start(1000)

        self.show_image(images.get())

    def show_image(self, image: Image.Image):
        qim = ImageQt(image)

        pixmap = QPixmap.fromImage(qim)
        self.label.setPixmap(pixmap)

    def next_image(self):
        self.image = images.get()

        log.info("Showing image", image=self.image)
        self.show_image(self.image)


def background_process(images: ImageQueue):
    counter = 0
    while True:
        image = get_next_frame()
        images.put(image)
        counter += 1
        sleep(1)


if __name__ == "__main__":
    app = QApplication(sys.argv)

    images: ImageQueue = Queue()

    p = Process(target=background_process, args=(images,))
    p.start()

    viewer = ImageViewer(images)
    viewer.show()
    try:
        sys.exit(app.exec())
    finally:
        p.terminate()
        p.join()
