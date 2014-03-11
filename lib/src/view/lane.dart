part of traffic_simulator;

class LaneView extends View<LaneController> {
  LaneView(CanvasElement canvas, Controller controller) :
      super(canvas, controller);

  Road get _road => controller.road;
  double get _width => controller.width;
  DoubleLinkedQueueEntry<LaneController> get _entry => controller.entry;
  int get _direction => controller.direction;

  @override
  void update() {
    transformMatrix = controller.road.view.transformMatrix.clone();
  }

  @override
  void render() {
    drawLane();
/*    for (var veh in vehicle) {
      // align the center of this lane to the x-axis
      Matrix3 tm = preTranslate(transformMatrix, 0.0, width / 2);
      if (this.direction == Road.BACKWARD) {
        // before that, swap the begin and end of the lane
        tm = tm * postTranslate(makeInvertXMatrix3(), road.length, 0.0);
      }
      veh.draw(camera, tm);
    }*/
  }

  void drawLane() {
    CanvasRenderingContext2D context = canvas.context2D;
    context.save();

    // top of this lane is aligned to x-axis
    transformContext(context, transformMatrix);

    // draw ground color
    context.beginPath();
    context.fillStyle = "black";
    context.fillRect(0, 0, _road.length, _width);
    context.setStrokeColorRgb(0, 0, 0);
    context.lineWidth = 1;
    context.strokeRect(0, 0, _road.length, _width);

    // lanes are ordered as inner-lane first
    if (_entry.nextEntry() == null) {
      if (_entry.previousEntry() == null) {
        if (_road.getOppositeLane(controller).firstEntry() == null) {
          // Single lane road
        }
        else {
          // Only single lane with this direction,
          // Next to its "inside" is an opposite-direction lane
          // Draw: insdie yellow line
          _beginPathInsideLine(context);
          _strokeSingleYellowLine(context);
        }
      }
      else {
        // Outermost lane with another same-direction lane inside
        // Draw: inside white line
//        _beginPathInsideLine(context);
        _beginPathInsideDash(context, 2.0, 1.0);
        _strokeWhiteLine(context);
      }
    }
    else {
      if (_entry.previousEntry() == null) {
        if (_road.getOppositeLane(controller).isEmpty) {
          // Outermost lane next to another same-directional lane.
          // This is a one-way traffic road with multiple lanes
//        _beginPathInsideLine(context);
          _beginPathInsideDash(context, 2.0, 1.0);
          _beginPathOutsideDash(context, 2.0, 1.0);
          _strokeWhiteLine(context);
        }
        else {
          // Middle road with its "inside" next to an opposite-direction lane
          // Draw: inside yello line, outside white line
          _beginPathInsideLine(context);
          _strokeSingleYellowLine(context);
          _beginPathOutsideDash(context, 2.0, 1.0);
          _strokeWhiteLine(context);
        }
      }
      else {
        // God bless it's just a simple middle lane!
        _beginPathInsideDash(context, 2.0, 1.0);
        _beginPathOutsideDash(context, 2.0, 1.0);
        _strokeWhiteLine(context);
      }
    }

    context.restore();
  }

  void _traceDashAtY(CanvasRenderingContext2D context,
                   double solidLength, double gapLength, double height) {
    double p = 0.0;
    context.moveTo(0, height);
    while (p < _road.length) {
      context.lineTo(p += solidLength, height);
      context.moveTo(p += gapLength, height);
    }
  }

  void _traceLineAtY(CanvasRenderingContext2D context, double height) {
    context.moveTo(0, height);
    context.lineTo(_road.length, height);
  }

  void _beginPathInsideLine(CanvasRenderingContext2D context) {
    context.beginPath();
    if ((_direction == Road.FORWARD && _road.drivingHand == Road.RHT) ||
        (_direction == Road.BACKWARD && _road.drivingHand == Road.LHT)) {
      // Inside is top
      _traceLineAtY(context, 0.0);
    }
    else {
      // Inside is bottom
      _traceLineAtY(context, _width);
    }
  }

  void _beginPathInsideDash(CanvasRenderingContext2D context,
                            double solidLength, double gapLength) {
    context.beginPath();
    if ((_direction == Road.FORWARD && _road.drivingHand == Road.RHT) ||
        (_direction == Road.BACKWARD && _road.drivingHand == Road.LHT)) {
      // Inside is top
      _traceDashAtY(context, solidLength, gapLength, 0.0);
    }
    else {
      // Inside is bottom
      _traceDashAtY(context, solidLength, gapLength, _width);
    }
  }

  void _beginPathOutsideLine(CanvasRenderingContext2D context) {
    context.beginPath();
    if ((_direction == Road.FORWARD && _road.drivingHand == Road.LHT) ||
        (_direction == Road.BACKWARD && _road.drivingHand == Road.RHT)) {
      // Outside is top
      _traceLineAtY(context, 0.0);
    }
    else {
      // Outside is bottom
      _traceLineAtY(context, _width);
    }
  }

  void _beginPathOutsideDash(CanvasRenderingContext2D context,
                             double solidLength, double gapLength) {
    context.beginPath();
    if ((_direction == Road.FORWARD && _road.drivingHand == Road.LHT) ||
        (_direction == Road.BACKWARD && _road.drivingHand == Road.RHT)) {
      // Outside is top
      _traceDashAtY(context, solidLength, gapLength, 0.0);
    }
    else {
      // Outside is bottom
      _traceDashAtY(context, solidLength, gapLength, _width);
    }
  }

  void _strokeSingleYellowLine(CanvasRenderingContext2D context) {
    context.setStrokeColorRgb(255, 255, 0);
    context.lineWidth = 0.4;
    context.stroke();
  }

  void _strokeWhiteLine(CanvasRenderingContext2D context) {
    context.setStrokeColorRgb(200, 200, 200);
    context.lineWidth = 0.4;
    context.stroke();
  }
}