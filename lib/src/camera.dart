part of traffic_simulator;

class Camera {
  Vector2 pos = new Vector2.zero(); // top-left corner
  Vector2 vel = new Vector2.zero();
  Vector2 _center = new Vector2.zero();
  double acc = 30.0;
  double maxSpeed = 60.0; // meter per click
  double height; // meters
  double ratio; // = width / height
  World world;
  double pixelPerMeter;
  CanvasElement canvas, buffer;
  double minZoomFactor = 0.2;
  // minZoomFactor <= zoomFactor <= 1 (fill the maximum world.canvas)
  double zoomFactor = 1.0;
  double get width => height * ratio; // meters
  double dt;
  Matrix3 transformMatrix;
  int maxHeightPixel;
  int maxWidthPixel;

  Camera(this.canvas, this.world, {this.pixelPerMeter: 10.0, Vector2
      center, this.maxHeightPixel: 0, this.maxWidthPixel: 0}) {
    buffer = new CanvasElement();
    onResize();
    if (center == null) {
      this.center = new Vector2.zero();
    } else {
      this.center = center;
    }
    pos = this.center;
  }

  void onResize() {
    ratio = canvas.width / canvas.height;
    if (maxHeightPixel > 0) {
      if (maxWidthPixel > 0) {
        // Choose the limiting one
        if (ratio < 1)  {
          // canvas.width < canvas.height, limit height
          if (canvas.height > maxHeightPixel) {
            buffer.height = maxHeightPixel;
          }
          else {
            buffer.height = canvas.height;
          }
          buffer.width = (buffer.height * ratio).toInt();
        }
        else {
          // canvas.width > canvas.height, limit width
          if (canvas.width > maxWidthPixel) {
            buffer.width = maxWidthPixel;
          }
          else {
            buffer.width = canvas.width;
          }
          buffer.height = (buffer.width ~/ ratio);
        }
      }
      else {
        // Only maxHeightPixel is given, limit height
        if (canvas.height > maxHeightPixel) {
          buffer.height = maxHeightPixel;
        }
        else {
          buffer.height = canvas.height;
        }
        buffer.width = (buffer.height * ratio).toInt();
      }
    }
    else {
      if (maxWidthPixel > 0) {
        // Only maxWidthPixel is given, limit width
        if (canvas.width > maxWidthPixel) {
          buffer.width = maxWidthPixel;
        }
        else {
          buffer.width = canvas.width;
        }
        buffer.height = (buffer.width ~/ ratio);
      }
      else {
        // No limit, use the original resolution of the device
        buffer
            ..width = canvas.width
            ..height = canvas.height;
      }
    }
    height = buffer.height.toDouble() / pixelPerMeter;
  }

  void set center(Vector2 c) {
    this._center.setValues(c.x - width / 2, c.y - height / 2);
  }

  Vector2 get center => this._center;

  void draw() {
    dt = world.gameLoop.dt * world.gameLoop.renderInterpolationFactor;
    transformMatrix = preTranslate(makeScaleMatrix3(pixelPerMeter), -(pos.x +
        vel.x * dt), -(pos.y + vel.y * dt));
    var bufferContext = buffer.context2D;
    bufferContext.clearRect(0, 0, buffer.width, buffer.height);
    bufferContext.save();
    // align the top left corner of the canvas to camera.pos
    transformContext(bufferContext, transformMatrix);
    world.draw(this);
    bufferContext.restore();
    canvas.context2D.clearRect(0, 0, canvas.width, canvas.height);
    //    canvas.context2D.drawImage(buffer, 0 , 0);
    canvas.context2D.drawImageScaled(buffer, 0, 0, canvas.width, canvas.height);
  }

  /*  void drawWorldBoundary() {
    CanvasRenderingContext2D context = canvas.context2D;
    context.save();

    context.beginPath();
    context.strokeStyle = "red";
    context.lineWidth = 5;
    context.strokeRect(0, 0, world.dimension.x, world.dimension.y);

    context.restore();
  }*/

  void zoom(double factor) {
    // prevent camera from zooming out of the world canvas
    double zoomFactorTest = zoomFactor * factor;
    //    if (zoomFactorTest >= minZoomFactor) {
    zoomFactor = zoomFactorTest;
    maxSpeed *= factor;
    acc *= factor;
    double dy = height * (1 - factor) / 2.0;
    height *= factor;
    pos.y += dy;
    pos.x += dy * ratio;
    pixelPerMeter /= factor;
    //    }
  }

  void zoomIn(double factor) => zoom(1.0 / factor);
  void zoomOut(double factor) => zoom(factor);

  void moveRight() {
    if (vel.x >= maxSpeed) {
      vel.x = maxSpeed;
    } else {
      vel.x += acc;
    }
  }

  void moveLeft() {
    if (vel.x < -maxSpeed) {
      vel.x = -maxSpeed;
    } else {
      vel.x -= acc;
    }
  }

  void moveUp() {
    if (vel.y < -maxSpeed) {
      vel.y = -maxSpeed;
    } else {
      vel.y -= acc;
    }
  }

  void moveDown() {
    if (vel.y > maxSpeed) {
      vel.y = maxSpeed;
    } else {
      vel.y += acc;
    }
  }

  void stopMove() {
    vel.setZero();
  }

  void update() {
    double dt = world.gameLoop.dt;
    pos += vel * dt;

    /*    double maxWidth_ = world.dimension.x - width;
    double maxHeight = world.dimension.y - height;

    if (pos.x < 0) {
      pos.x = 0.0;
      vel.x = 0.0;
    }
    else if (pos.x > maxWidth_) {
      pos.x = maxWidth_;
      vel.x = 0.0;
    }
    if (pos.y < 0) {
      pos.y = 0.0;
      vel.y = 0.0;
    }
    else if (pos.y > maxHeight) {
      pos.y = maxHeight;
      vel.y = 0.0;
    }*/
  }

  void reset() {
    zoom(1 / zoomFactor);
    vel.setZero();
    pos.setFrom(_center);
  }

  void toCenter() {
    var zm = zoomFactor;
    reset();
    zoom(zm);
  }
}

class Color {
  int r, g, b;
  num a = 1;
  static Random _rand = new Random();

  Color(this.r, this.g, this.b, [this.a]);

  Color.red() {
    r = 255;
    g = 0;
    b = 0;
  }

  Color.black() {
    r = 0;
    g = 0;
    b = 0;
  }

  /**
   * [min] and [max] should be integers 0-255
   * [max] should be greater than [min]
   *
   * No check is performed for efficiency
   */
  Color.random({int min: 0, int max: 255}) {
    r = _rand.nextInt(max - min + 1) + min;
    g = _rand.nextInt(max - min + 1) + min;
    b = _rand.nextInt(max - min + 1) + min;
  }

  Color clone() {
    return new Color(r, g, b, a);
  }

  @override
  bool operator ==(Color other) {
    if (r == other.r && g == other.g && b == other.b && a == other.a) {
      return true;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return (a + 1) * 10000000 + (r + 1) * 1000000 + (g + 1) * 1000 + b;
  }
}
