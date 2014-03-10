part of traffic_simulator;

class Vehicle implements Controller {
  World world;
  VehicleModel model;
  VehicleView view;

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

  double get pos => model.pos;
  set pos(double pos) => model.pos = pos;
  set lane(Lane lane) => model.lane = lane;

  void update() {
    double dt = world.dtUpdate;
    vel += acc*dt;
    if (vel > velMax) {
      vel = velMax;
    }
    pos += vel*dt;
    driver.update();
  }
}