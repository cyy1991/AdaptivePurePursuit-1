// All functions related to the robot following the path

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
