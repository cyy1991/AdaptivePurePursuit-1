// All functions related to generating the path

void injectWaypoints() {
    injectedPoints.clear();

    // Loop through all segments
    for(int i = 0; i < userPoints.size() - 1; i++) {
        Waypoint a = userPoints.get(i);
        Waypoint b = userPoints.get(i + 1);

        Vector vector = b.getVector().sub(a.getVector());
        int numPoints = (int) Math.ceil(vector.getMag() / SPACING);
        Vector dVector = vector.normalize().mult(SPACING);

        for(int j = 0; j < numPoints; j++) {
            injectedPoints.add(new Waypoint(a.getVector().add(dVector.mult(j))));
        }
    }
    injectedPoints.add(userPoints.get(userPoints.size() - 1));
}

void smoothWaypoints() {
    smoothedPoints.clear();

    for(Waypoint waypoint : injectedPoints) {
        smoothedPoints.add(new Waypoint(waypoint));
    }

    double change = TOLERANCE;
    while(change >= TOLERANCE) {
        change = 0.0;
        for(int i = 1; i < smoothedPoints.size() - 1; i++) {
            Waypoint current = smoothedPoints.get(i);
            Waypoint prev = smoothedPoints.get(i - 1);
            Waypoint next = smoothedPoints.get(i + 1);

            Waypoint origCurrent = injectedPoints.get(i);

            // x smoothing
            double compX = current.getX();
            double newX = current.getX() + WEIGHT_DATA * (origCurrent.getX() - current.getX()) + 
                WEIGHT_SMOOTH * (prev.getX() + next.getX() - (2 * current.getX()));
            current.setX(newX);
            change += Math.abs(compX - newX);

            // y smoothing
            double compY = current.getY();
            double newY = current.getY() + WEIGHT_DATA * (origCurrent.getY() - current.getY()) + 
                WEIGHT_SMOOTH * (prev.getY() + next.getY() - (2 * current.getY()));
            current.setY(newY);
            change += Math.abs(compY - newY);
        }
    }
}

void calculateDistances() {
    distancePath.clear();

    for(int i = 0; i < smoothedPoints.size(); i++) {
        if(i == 0) {
            distancePath.add(0.0d);
            distanceBetween.add(0.0d);
        }
        else {
            Waypoint prev = smoothedPoints.get(i - 1);
            Waypoint curr = smoothedPoints.get(i);
            double distance = curr.getDistanceTo(prev);
            distancePath.add(distance + distancePath.get(i - 1));
            distanceBetween.add(distance);
        }
    }
}

void calculateCurvatures() {
    curvatures.clear();

    for(int i = 0; i < smoothedPoints.size(); i++) {
        if(i == 0 || i == smoothedPoints.size() - 1) {
            curvatures.add(0.0d);
        }
        else {
            Waypoint curr = smoothedPoints.get(i);
            Waypoint prev = smoothedPoints.get(i - 1);
            Waypoint next = smoothedPoints.get(i + 1);

            double x1 = curr.getX() + 0.001; // get rid of divide by 0
            double y1 = curr.getY();

            double x2 = prev.getX();
            double y2 = prev.getY();

            double x3 = next.getX();
            double y3 = next.getY();

            double k1 = 0.5 * (x1 * x1 + y1 * y1 - x2 * x2 - y2 * y2) / (x1 - x2);
            double k2 = (y1 - y2) / (x1 - x2);
            double b = 0.5 * (x2 * x2 - 2 * x2 * k1 + y2 * y2 - x3 * x3 + 2 * x3 * k1 - y3 * y3) / 
                (x3 * k2 - y3 + y2 - x2 * k2);
            double a = k1 - k2 * b;
            double r = Math.sqrt((x1 - a) * (x1 - a) + (y1 - b) + (y1 - b));
            double curvature = 1.0 / r;

            if(Double.isNaN(curvature)) {
                curvature = 0.0;
            }

            curvatures.add(curvature);
        }
    }
}

// Calculates the target velocity for each point using curvature and decceleration
// Must call calculateDistances() before calling this
void calculateTargetVelocities() {
    for(int i = 0; i < smoothedPoints.size(); i++) {
        // Set up initial value for each point's velocity via curvature
        smoothedPoints.get(i).setTargetVelocity(Math.min(MAX_VELOCITY, 
            TURNING_CONSTANT / curvatures.get(i)));
    }

    // Limit each point's velocity via acceleration
    // Loops through backwards
    for(int i = smoothedPoints.size() - 1; i >= 0; i--) {
        if(i == smoothedPoints.size() - 1) {
            smoothedPoints.get(i).setTargetVelocity(0.0);
        }
        else {
            double distance = distanceBetween.get(i + 1);
            double nextVelocity = smoothedPoints.get(i + 1).getTargetVelocity();
            double calculatedSpeed = Math.sqrt(nextVelocity * nextVelocity + 
                2.0 * MAX_ACCELERATION * distance);

            smoothedPoints.get(i).setTargetVelocity(Math.min(smoothedPoints.get(i).getTargetVelocity(), 
                calculatedSpeed));
        }
    }
}
