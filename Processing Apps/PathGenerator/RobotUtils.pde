// All functions related to the robot following the path

// Gets the waypoint closest to the given coordinates
Waypoint getClosestPoint(double x, double y) {
    Waypoint closest = null;
    double closestDist = -1;

    for(Waypoint waypoint : smoothedPoints) {
        if(closest == null) {
            closest = waypoint;
            closestDist = waypoint.getDistanceTo(x, y);
        }
        else {
            double checkDist = waypoint.getDistanceTo(x, y);
            if(checkDist <= closestDist) {
                closest = waypoint;
            }
        }
    }

    return closest;
}

