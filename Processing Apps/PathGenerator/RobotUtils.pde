// All functions related to the robot following the path

// TODO Optimize the distance functions w/ distance squared

// Gets the index of the waypoint closest to the given coordinates and 
// uses the last found point to optimize the search
int getClosestPoint(double x, double y, int lastPoint) {
    int index = -1;
    double closestDist = -1;

    for(int i = lastPoint; i < smoothedPoints.size(); i++) {
        Waypoint waypoint = smoothedPoints.get(i);
        double checkDist = waypoint.getDistanceTo(x, y);

        if(index == -1) {
            index = i;
            closestDist = checkDist;
        }
        else {
            if(checkDist <= closestDist) {
                index = i;
                closestDist = checkDist;
            }
        }
    }

    return index;
}

class LookAheadResult {
    public double t;
    public int i;
    public Vector lookAhead;

    public LookAheadResult(double t, int i, Vector lookAhead) {
        this.t = t;
        this.i = i;
        this.lookAhead = lookAhead;
    }
}

// Calculate the next look ahead point and uses the last found point to ensure only forward progress is made
LookAheadResult getLookAheadPoint(double x, double y, double lastT, int lastIndex) {
    Vector pos = new Vector(x, y);
    for(int i = lastIndex; i < smoothedPoints.size() - 1; i++) {
        Waypoint a = smoothedPoints.get(i);
        Waypoint b = smoothedPoints.get(i + 1);

        double t = getLookAheadPointT(pos, a.getVector(), b.getVector());
        if(t != -1) {
            // If the segment is further along or the fractional index is greater, then this is the correct point
            if(i > lastIndex || t > lastT) {
                Vector d = b.getVector().sub(a.getVector());
                return new LookAheadResult(t, i, a.getVector().add(d.mult(t)));
            }
        }
    }

    // Just return last look ahead result
    Waypoint a = smoothedPoints.get(lastIndex);
    Waypoint b = smoothedPoints.get(lastIndex + 1);
    Vector d = b.getVector().sub(a.getVector());

    return new LookAheadResult(lastT, lastIndex, a.getVector().add(d.mult(lastT)));
}

double getLookAheadPointT(Vector pos, Vector start, Vector end) {
    Vector d = end.sub(start);
    Vector f = start.sub(pos);

    double a = d.dot(d);
    double b = 2.0 * f.dot(d);
    double c = f.dot(f) - LOOKAHEAD * LOOKAHEAD;

    double discriminant = b * b - 4 * a * c;

    if(discriminant < 0) {
        return -1;
    }
    else {
        discriminant = Math.sqrt(discriminant);
        double t1 = (-b - discriminant) / (2 * a);
        double t2 = (-b + discriminant) / (2 * a);

        if(t1 >= 0 && t1 <= 1) {
            return t1;
        }
        if(t2 >= 0 && t2 <= 1) {
            return t2;
        }
    }

    return -1;
}

// angle is in radians
double getCurvatureToPoint(Vector pos, double angle, Vector lookAhead) {
    double a = -Math.tan(angle);
    double b = 1.0;
    double c = Math.tan(angle) * pos.getX() - pos.getY();

    double x = Math.abs(a * lookAhead.getX() + b * lookAhead.getY() + c) / Math.sqrt(a * a + b * b);
    double l = pos.getDistanceTo(lookAhead);
    double curvature = 2 * x / l / l;

    Vector otherPoint = pos.add(new Vector(Math.cos(angle), Math.sin(angle)));
    double side = Math.signum((otherPoint.getY() - pos.getY()) * (lookAhead.getX() - pos.getX()) - 
        (otherPoint.getX() - pos.getX()) * (lookAhead.getY() - robot.getY()));

    return curvature * side;
}

double pathLastT = 0.0;
int pathLastLookAheadIndex = 0;
int pathLastClosestIndex = 0;
double left = 0;
double right = 0;
long lastCall = -1;

void followPath() {
    Vector robotPos = robot.getPos();
    LookAheadResult lookAheadResult = getLookAheadPoint(robotPos.getX(), robotPos.getY(), 
        pathLastT, pathLastLookAheadIndex);
    pathLastT = lookAheadResult.t;
    pathLastLookAheadIndex = lookAheadResult.i;
    Vector lookAheadPoint = lookAheadResult.lookAhead;

    double curvature = getCurvatureToPoint(robotPos, robot.getAngle(), lookAheadPoint);
    pathLastClosestIndex = getClosestPoint(robotPos.getX(), robotPos.getY(), pathLastClosestIndex);
    double targetVelocity = smoothedPoints.get(pathLastClosestIndex).getTargetVelocity();

    double tempLeft = targetVelocity * (2.0 + curvature * DRIVE_WIDTH) / 2.0;
    double tempRight = targetVelocity * (2.0 - curvature * DRIVE_WIDTH) / 2.0;

    if(lastCall == -1) lastCall = millis();
    double maxChange = (millis() - lastCall) * MAX_ACCELERATION;
    left += constrainDouble(tempLeft - left, maxChange, -maxChange);
    right += constrainDouble(tempRight - right, maxChange, -maxChange);

    robot.setLeft(left);
    robot.setRight(right);

    lastCall = millis();
}

double constrainDouble(double value, double max, double min) {
    if(value < min) return min;
    if(value > max) return max;
    return value;
}