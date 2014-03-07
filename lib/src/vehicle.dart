part of traffic_simulator;

class Vehicle implements Backtraceable {
  double pos = 0.0;
  double vel = 10.0;
  double acc = 0.0;
  double accMax;
  double velMax;
  Lane lane;
  Driver driver;
  double width;
  double length;
  DoubleLinkedQueueEntry entry;
  TrafficSimulator world;
  Color color;

  Vehicle(this.world, {this.width: 1.6, this.length: 3.5, this.accMax,
                       this.velMax, this.color, this.driver}) {
    if (driver == null) {
      this.driver = new Driver(world, vehicle: this);
    }

    if (color == null) {
      do {
        color = new Color(world.random.nextInt(2)*255, world.random.nextInt(2)*255,
          world.random.nextInt(2)*255);
      } while (color.r == 0 && color.g == 0 && color.b == 0);
    }

    if (accMax == null) {
      accMax = world.random.nextDouble() * 10 + 5;
    }

    if (velMax == null) {
      velMax = world.random.nextDouble() * 20 + 10;
    }
  }

  void draw(Camera camera, Matrix3 transformMatrix) {
    // the lane center is x-aixs, lane begins from origin to the positive x
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();

    transformContext(context, preTranslate(transformMatrix, pos + vel * world.dt, 0.0));
    // draw as if the reference point of the vehicle is the origin

    context.setFillColorRgb(color.r, color.g, color.b);
    context.fillRect(-length, -width / 2, length, width);
    context.restore();
  }

  void update() {
    double dt = lane.road.world.gameLoop.dt;
    vel += acc*dt;
    if (vel > velMax) {
      vel = velMax;
    }
    pos += vel*dt;
    driver.update();
  }
}
