part of traffic_simulator;

abstract class Joint {
  Set<RoadEnd> roadEnd = new Set<RoadEnd>();
  Set<RoadEnd> _inwardRoadEnd =  new Set<RoadEnd>();
  Set<RoadEnd> _outwardRoadEnd =  new Set<RoadEnd>();
  String label = "";
  Color labelCircleColor;
  
  Joint(String this.label) {
    labelCircleColor = new Color.random(min: 100);
  }
  
  TrafficSimulator world;
    
  void addRoadEnd(RoadEnd roadEnd) {
    this.roadEnd.add(roadEnd);
    updateOnRoadChange();
  }
  
  void removeRoadEnd(RoadEnd end) {
    roadEnd.remove(end);
    updateOnRoadChange();
  }
  
  void updateOnRoadChange() {
    _inwardRoadEnd.clear();
    _outwardRoadEnd.clear();
    for (var roadEnd in this.roadEnd) {
      if (roadEnd.outwardLane.length > 0) _outwardRoadEnd.add(roadEnd);
      if (roadEnd.inwardLane.length > 0) _inwardRoadEnd.add(roadEnd);
    }
  }
  
  void draw(Camera camera);
  
  void drawLabel(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    for (var roadEnd in this.roadEnd) {
      context.save();
      transformContext(context, makeTranslateMatrix3(roadEnd.pos.x, roadEnd.pos.y));
      context.beginPath();
      context.arc(0, 0, roadEnd.road.width / 2, 0, 2*PI);
      context.setFillColorRgb(labelCircleColor.r, labelCircleColor.g,
          labelCircleColor.b);
      context.fill();
      context.textAlign = "center";
      context.textBaseline = "middle";
      context.setFillColorRgb(0, 0, 0);
      
      // Use larger font first then scale down to workaround the
      // minimum font size problem in Chrome
      context.save();
      context.scale(0.25, 0.25);
      context.font = "16px arial";
      context.fillText(label, 0, 0.4*4);
      context.restore();
      
      context.restore();
    }
  }
  
  Lane getRandomOutwardLane() {
    var max = _outwardRoadEnd.length;
    if (max > 0) {
      return _outwardRoadEnd.elementAt(world.random.nextInt(max)).getRandomOutwardLane();
    }
    else {
      return null;
    }
  }
  
  void update();
}

class SourceJoint extends Joint {
  double spawnInterval = 1.0;
  double accumulatedTime = 0.0;
  double _opacity;
  double opacityFreq = 0.5;
  double maxOpacity = 0.5;
  double minOpacity = 0.1;
  int maxDispatch = 10;
  
  SourceJoint(String label) : super(label) {
    _opacity = maxOpacity;
  }
 
  @override
  void update() {
    if (maxDispatch > 0) {
      if (accumulatedTime < spawnInterval) {
        accumulatedTime += world.gameLoop.dt;
      }
      else {
        accumulatedTime = 0.0;
        randomDispatch();
        maxDispatch--;
      }
      _updateBlink();
    }
    else {
      _opacity = -1.0;
    }
  }
  
  void _updateBlink() {
    _opacity += opacityFreq * world.gameLoop.dt;    
    if (_opacity > maxOpacity) {
      _opacity = maxOpacity;
      opacityFreq *= -1;      
    }
    else if (_opacity < minOpacity) {
      _opacity = minOpacity;
      opacityFreq *= -1;      
    }    
  }
  
  void randomDispatch() {
    // Randomly pick a roadEnd to add
    var roadEnd = _outwardRoadEnd.elementAt(world.random.nextInt(_outwardRoadEnd.length));
    roadEnd.requestAddVehicle(world.requestVehicle());
  }
  
  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    for (var roadEnd in this.roadEnd) {
      context.save();
      transformContext(context, makeTranslateMatrix3(roadEnd.pos.x, roadEnd.pos.y));
      context.beginPath();
      context.arc(0, 0, roadEnd.road.width / 2 + 2, 0, 2*PI);
      if (_opacity >= 0) {
        context.setFillColorRgb(200, 0, 0, _opacity + opacityFreq * camera.dt);
        context.fill();
      }
      context.restore();
    }
    drawLabel(camera);
  }
}