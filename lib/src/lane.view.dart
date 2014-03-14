part of traffic_simulator;

class LaneView implements View {
  Lane model;
  LaneView(this.model);
  Matrix3 transformMatrix;

  void draw(Camera camera) {
    _drawLane(camera);
    for (var veh in model.vehicle) {
      veh.view.draw(camera);
    }
  }

  void _drawLane(Camera camera) {
    CanvasRenderingContext2D context = camera.buffer.context2D;
    context.save();

    // top of this lane is aligned to x-axis
    transformContext(context, transformMatrix);

    // draw ground color
    context.beginPath();
    context.fillStyle = "black";
    context.fillRect(0, 0, model.road.length, model.width);
    context.setStrokeColorRgb(0, 0, 0);
    context.lineWidth = 1 / camera.pixelPerMeter;
    context.strokeRect(0, 0, model.road.length, model.width);

    // lanes are ordered as inner-lane first
    if (model.entry.nextEntry() == null) {
      if (model.entry.previousEntry() == null) {
        if (model.road._getOppositeLane(model).isEmpty) {
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
        _beginPathInsideDash(context, 5.0, 5.0);
        _strokeWhiteLine(context);
      }
    }
    else {
      if (model.entry.previousEntry() == null) {
        if (model.road._getOppositeLane(model).isEmpty) {
          // Outermost lane next to another same-directional lane.
          // This is a one-way traffic road with multiple lanes
//        _beginPathInsideLine(context);
          _beginPathInsideDash(context, 5.0, 5.0);
          _beginPathOutsideDash(context, 5.0, 5.0);
          _strokeWhiteLine(context);
        }
        else {
          // Middle road with its "inside" next to an opposite-direction lane
          // Draw: inside yello line, outside white line
          _beginPathInsideLine(context);
          _strokeSingleYellowLine(context);
          _beginPathOutsideDash(context, 5.0, 5.0);
          _strokeWhiteLine(context);
        }
      }
      else {
        // God bless it's just a simple middle lane!
        _beginPathInsideDash(context, 5.0, 5.0);
        _beginPathOutsideDash(context, 5.0, 5.0);
        _strokeWhiteLine(context);
      }
    }

    context.restore();
  }

  void _traceDashAtY(CanvasRenderingContext2D context,
                   double solidLength, double gapLength, double height) {
    double p = 0.0;
    context.moveTo(0, height);
    while (p < model.road.length) {
      context.lineTo(p += solidLength, height);
      context.moveTo(p += gapLength, height);
    }
  }

  void _traceLineAtY(CanvasRenderingContext2D context, double height) {
    context.moveTo(0, height);
    context.lineTo(model.road.length, height);
  }

  void _beginPathInsideLine(CanvasRenderingContext2D context) {
    context.beginPath();
    if ((model.direction == Road.FORWARD && model.road.drivingSide == Road.RHT) ||
        (model.direction == Road.BACKWARD && model.road.drivingSide == Road.LHT)) {
      // Inside is top
      _traceLineAtY(context, 0.0);
    }
    else {
      // Inside is bottom
      _traceLineAtY(context, model.width);
    }
  }

  void _beginPathInsideDash(CanvasRenderingContext2D context,
                            double solidLength, double gapLength) {
    context.beginPath();
    if ((model.direction == Road.FORWARD && model.road.drivingSide == Road.RHT) ||
        (model.direction == Road.BACKWARD && model.road.drivingSide == Road.LHT)) {
      // Inside is top
      _traceDashAtY(context, solidLength, gapLength, 0.0);
    }
    else {
      // Inside is bottom
      _traceDashAtY(context, solidLength, gapLength, model.width);
    }
  }

  void _beginPathOutsideLine(CanvasRenderingContext2D context) {
    context.beginPath();
    if ((model.direction == Road.FORWARD && model.road.drivingSide == Road.LHT) ||
        (model.direction == Road.BACKWARD && model.road.drivingSide == Road.RHT)) {
      // Outside is top
      _traceLineAtY(context, 0.0);
    }
    else {
      // Outside is bottom
      _traceLineAtY(context, model.width);
    }
  }

  void _beginPathOutsideDash(CanvasRenderingContext2D context,
                             double solidLength, double gapLength) {
    context.beginPath();
    if ((model.direction == Road.FORWARD && model.road.drivingSide == Road.LHT) ||
        (model.direction == Road.BACKWARD && model.road.drivingSide == Road.RHT)) {
      // Outside is top
      _traceDashAtY(context, solidLength, gapLength, 0.0);
    }
    else {
      // Outside is bottom
      _traceDashAtY(context, solidLength, gapLength, model.width);
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

  @override
  void update() {
    // TODO: implement update
  }
}
